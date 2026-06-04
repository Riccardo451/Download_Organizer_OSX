# 📁 Smart Folder Organizer (macOS Bash Tool)

A robust Bash utility that automatically organizes files using MIME types, supports recursive scanning, persistent duplicate detection, and includes a safe undo system. Designed to work seamlessly on macOS (including Automator) and Linux.

---

## 🚀 Features

### 📂 Automatic file organization
Files are grouped based on MIME type using the `file --mime-type` command:

- Images
- Videos
- Audio
- Documents
- PDFs
- Archives
- Applications
- Other

---

### 🔁 Recursive processing
Scans all files in the target directory, including all subfolders, and organizes them in place.

---

### 🧬 Persistent duplicate detection
When enabled, the script:

- Computes SHA-256 hashes for each file
- Stores them in a persistent database (`.organizer.hashdb`)
- Detects duplicates across multiple runs
- Moves duplicates into a `Duplicates/` folder instead of deleting them

---

### ⚔️ Safe conflict resolution
If a file with the same name already exists, the script automatically renames it:


file.pdf
file (1).pdf
file (2).pdf


---

### ↩️ Undo system
Every move is recorded in `.organizer.undo`, allowing you to revert the last run safely.

---

### 🧾 Logging
All operations are logged to:


.organizer.log


This includes file moves, duplicates, and run timestamps.

---

## 📦 Generated files and folders

Inside the target directory, the script may create:


.organizer.log # Activity log
.organizer.undo # Undo history
.organizer.hashdb # Persistent duplicate database
Duplicates/ # Duplicate files
Images/
Videos/
Audio/
Documents/
PDFs/
Archives/
Applications/
Other/


---

## 🛠️ Requirements

- macOS or Linux
- Bash 4+
- `find`
- `file`
- `shasum` (preinstalled on macOS)

---

## 📥 Installation

```bash
git clone https://your-repo-url.git
cd your-repo
chmod +x organizer.sh
🚀 Usage
Basic usage

Organize a folder:

./organizer.sh /path/to/folder
Enable persistent duplicate detection
./organizer.sh /path/to/folder --dedupe
Undo last run
./organizer.sh /path/to/folder --undo
🧠 How duplicate detection works

When --dedupe is enabled:

Each file is hashed using SHA-256
Hashes are stored in .organizer.hashdb
If a hash already exists:
The file is considered a duplicate
It is moved to Duplicates/
Otherwise:
The hash is stored for future runs

This allows duplicate detection across multiple runs, not just within a single execution.

⚠️ Safety notes
No files are deleted — only moved
Undo only restores the most recent run
Hidden files (.*) are ignored
System and script files are excluded automatically
All operations are reversible via logs
🍎 Automator integration (macOS)

To use with Automator Folder Actions:

cd "$1" && /path/to/organizer.sh "$1"

Or attach it directly to the Downloads folder.

🔮 Possible future improvements
AI-based smart categorization (Work / Personal / Media)
Background watcher for real-time Downloads sorting
Finder right-click integration
Duplicate similarity detection (beyond exact hashes)
Parallel processing for large folders
GUI version for macOS
👤 Notes

This tool is designed to prioritize:

Safety (no deletion)
Reversibility (undo system)
Transparency (logging)
Cross-run intelligence (persistent hashing)
