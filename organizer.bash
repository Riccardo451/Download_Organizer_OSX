#!/bin/bash 
set -e 
set -u 
set -o pipefail

# Set folder action on automator with folder action download and shell script:
# cd /Users/USER_NAME/Downloads/ && /Users/USER_NAME/Documents/automation/organizer.bash "$1"

start=$SECONDS

exts=$(ls -dp *.* | grep -v / | sed 's/^.*\.//' | sort -u) # not folders
ignore=""

while getopts ':f::i:h' flag; do
  case "$flag" in
    h)
        echo " "
        echo "This script sorts files from the current dir into folders of the same file type. "

        echo "Specific file types can be specified using -f."
        echo "flags:"
        echo "-h for helper"
        echo "-f (string file types to sort e.g. -f "pdf csv mp3")"
        echo "-i (string file types to ignore e.g. -i "pdf")"
        echo " "
        exit 1
        ;;
    f)
        exts=$OPTARG;;
    i)
        ignore=$OPTARG;;
    :) 
        echo "Missing option argument for -$OPTARG" >&2; 
        exit 1;;
    \?)
        echo "Invalid option: -$OPTARG" >&2
        exit 1
        ;;
  esac
done

for ext in $exts
do  
    if [[ " ${ignore} " == *" ${ext} "* ]]; then
        echo "Skiping ${ext}"
        continue
    fi
    echo Processing "$ext"
    mkdir -m 777 -p "$ext"
    mv -vn *."$ext" "$ext"/
done

duration=$(( SECONDS - start ))
echo "--- Completed in $duration seconds ---"