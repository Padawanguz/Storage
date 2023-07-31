#!/bin/bash

# Check for required commands
for cmd in dmenu awk; do
  if ! command -v "$cmd" >/dev/null 2>&1; then
    echo "Error: Required command '$cmd' not found" >&2
    exit 1
  fi
done

# Find the terminal emulator
get_terminal() {
  terminal=$(command -v st kitty rxvt sakura lilyterm roxterm termite Alacritty xterm 2>/dev/null | head -n 1)
  if [ -z "$terminal" ]; then
    echo "No terminal emulator found. This script requires a terminal emulator to be installed."
    exit 1
  fi
  echo "$terminal"
}

# directory for storing the index
index_dir="$HOME/.cache/dmenu_utilities"

# check if index directory exists
if [ ! -d "$index_dir" ]; then
  mkdir "$index_dir" || { echo "Error: Failed to create directory '$index_dir'"; exit 1; }
fi

# file to store the index
index_file="$index_dir/dir_index.txt"

# Create the index if it doesn't exist
if [ ! -f "$index_file" ]; then
  find ~ -not -path '*/\.*' -type d 2>/dev/null > "$index_file"
fi

# get a directory from the user
dir=$(dmenu -i -l 20 < "$index_file") || { echo "Error: Failed to get directory from user"; exit 1; }

# open the selected directory in st terminal
terminal=$(get_terminal)
if [ -n "$dir" ]; then
    $terminal -e "$SHELL" -c "cd \"$dir\"; ls -lh; exec $SHELL"
fi
