#!/bin/bash
FILE="$1"

if [ -z "$FILE" ]; then
    echo "Error: No filename provided"
    echo "Usage: ./check_file.sh <filename>"
    exit 1
fi

if [ -f "$FILE" ]; then
    echo "File exists: $FILE"
elif [ -d "$FILE" ]; then
    echo "That is a directory, not a file: $FILE"
else
    echo "File does not exist: $FILE"
fi
