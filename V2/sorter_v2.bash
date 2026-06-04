#!/bin/bash
set -euo pipefail

########################################
# CONFIG
########################################

BASE_DIR="${1:-$PWD}"
DEDUP_FLAG="${2:-}"
LOG_FILE="$BASE_DIR/.organizer.log"
UNDO_FILE="$BASE_DIR/.organizer.undo"
HASH_DB="$BASE_DIR/.organizer.hashdb"

mkdir -p "$BASE_DIR"
touch "$HASH_DB"

echo "==== Run started at $(date) ====" >> "$LOG_FILE"

########################################
# LOAD PERSISTENT HASH DB
########################################

declare -A hash_index

while IFS="|" read -r hash path; do
  [[ -n "${hash:-}" ]] && hash_index["$hash"]="$path"
done < "$HASH_DB"

########################################
# FUNCTIONS
########################################

file_hash() {
  shasum -a 256 "$1" | awk '{print $1}'
}

get_category() {
  local mime="$1"

  case "$mime" in
    image/*) echo "Images" ;;
    video/*) echo "Videos" ;;
    audio/*) echo "Audio" ;;
    text/*)  echo "Documents" ;;
    application/pdf) echo "PDFs" ;;
    application/zip|application/x-tar|application/gzip) echo "Archives" ;;
    application/*) echo "Applications" ;;
    *) echo "Other" ;;
  esac
}

log_move() {
  echo "$1|$2" >> "$UNDO_FILE"
  echo "Moved: $2 -> $1" >> "$LOG_FILE"
}

safe_move() {
  local src="$1"
  local dest_dir="$2"

  mkdir -p "$dest_dir"

  local filename dest base ext counter

  filename="$(basename "$src")"
  dest="$dest_dir/$filename"

  # conflict resolution
  if [[ -e "$dest" ]]; then
    base="${filename%.*}"
    ext="${filename##*.}"
    counter=1

    while [[ -e "$dest_dir/${base} ($counter).$ext" ]]; do
      ((counter++))
    done

    dest="$dest_dir/${base} ($counter).$ext"
  fi

  mv "$src" "$dest"
  log_move "$dest" "$src"
}

########################################
# UNDO MODE
########################################

if [[ "$DEDUP_FLAG" == "--undo" ]]; then
  echo "Undoing..." | tee -a "$LOG_FILE"

  [[ -f "$UNDO_FILE" ]] || exit 0

  while IFS="|" read -r dest src; do
    [[ -e "$dest" ]] && mv "$dest" "$src"
  done < "$UNDO_FILE"

  rm -f "$UNDO_FILE"
  echo "Undo complete." | tee -a "$LOG_FILE"
  exit 0
fi

########################################
# DEDUPE MODE
########################################

DEDUP=0
if [[ "$DEDUP_FLAG" == "--dedupe" ]]; then
  DEDUP=1
  echo "Persistent dedupe enabled" >> "$LOG_FILE"
fi

########################################
# MAIN LOOP
########################################

find "$BASE_DIR" -type f ! -path "*/.*" -print0 | while IFS= read -r -d '' file; do

  [[ "$file" == "$LOG_FILE" || "$file" == "$UNDO_FILE" || "$file" == "$HASH_DB" ]] && continue

  # ---- HASHING ----
  hash=$(file_hash "$file")

  # ---- PERSISTENT DUPLICATE CHECK ----
  if [[ "$DEDUP" -eq 1 ]]; then
    if [[ -n "${hash_index[$hash]:-}" ]]; then

      dup_dir="$BASE_DIR/Duplicates"
      mkdir -p "$dup_dir"

      filename="$(basename "$file")"
      dest="$dup_dir/$filename"

      # resolve duplicates inside duplicates folder
      if [[ -e "$dest" ]]; then
        base="${filename%.*}"
        ext="${filename##*.}"
        counter=1

        while [[ -e "$dup_dir/${base} (dup $counter).$ext" ]]; do
          ((counter++))
        done

        dest="$dup_dir/${base} (dup $counter).$ext"
      fi

      mv "$file" "$dest"
      log_move "$dest" "$file"

      continue
    fi

    # store new hash permanently
    hash_index["$hash"]="$file"
    echo "$hash|$file" >> "$HASH_DB"
  fi

  # ---- MIME CLASSIFICATION ----
  mime=$(file --mime-type -b "$file" 2>/dev/null || echo "unknown/unknown")
  category=$(get_category "$mime")

  safe_move "$file" "$BASE_DIR/$category"

done

echo "==== Run finished at $(date) ====" >> "$LOG_FILE"
echo "Done."
