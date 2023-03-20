#!/bin/bash 
set -e # Exit immediately if a command exits with a non-zero status
set -u # Treat unset variables and parameters as an error when performing parameter expansion
set -o pipefail # Return value of a pipeline is the value of the last (rightmost) command to exit with a non-zero status

# Set folder action on automator with folder action download and shell script:
# cd /Users/user/Downloads/ && /Users/user/Documents/automation/organizer.bash "$1"

start=$SECONDS

exts=$(ls -dp *.* | grep -v / | sed 's/^.*\.//' | sort -u) # Get all file extensions in current directory (not folders)
ignore=""

while getopts ':f::i:h' flag; do # Parse command line options
  case "$flag" in
    h) # Help flag
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
    f) # File types to sort flag
        exts=$OPTARG;;
    i) # File types to ignore flag
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

for ext in $exts # Loop through all file extensions in current directory or specified by user using `-f` flag
do  
    if [[ " ${ignore} " == *" ${ext} "* ]]; then # Check if extension is in ignore list specified by user using `-i` flag
        echo "Skiping ${ext}"
        continue
    fi
    
    echo Processing "$ext"
    
    mkdir -m 777 -p "$ext" # Create directory for extension if it doesn't exist
    
    mv -vn *."$ext" "$ext"/ # Move all files with extension into corresponding directory
    
done

duration=$(( SECONDS - start ))
echo "--- Completed in $duration seconds ---"