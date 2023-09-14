#!/bin/bash

# Check if the correct number of arguments is provided
if [ $# -ne 2 ]; then
  echo "Usage: $0 <folder_path> <number_of_days>"
  exit 1
fi

# Store the provided folder path and number of days in variables
folder="$1"
num_days="$2"

# Check if the provided number of days is a positive integer
if ! [[ "$num_days" =~ ^[0-9]+$ ]]; then
  echo "Error: Please provide a positive integer for the number of days."
  exit 1
fi

# Check if the provided folder exists
if [ ! -d "$folder" ]; then
  echo "Error: The specified folder does not exist."
  exit 1
fi

# Use the find command to delete files older than the specified number of days
find "$folder" -type f -mtime +$num_days -exec rm {} \;
echo "Files older than $num_days days in $folder have been deleted."