#!/bin/bash

# Define directories to watch and index files
dir_to_watch=$HOME
file_index="$HOME/dmenu_file_browser_index"
dir_index="$HOME/dmenu_dir_browser_index"
hidden_file_index="$HOME/dmenu_hidden_file_browser_index"
hidden_dir_index="$HOME/dmenu_hidden_dir_browser_index"

# Define directories to exclude with $HOME
EXCLUDE_DIRS=(
  "$HOME/.cache"
  "$HOME/.local/share/Trash"
  "$HOME/.mozilla"
  "$HOME/.google-chrome"
  "$HOME/.thunderbird"
  "$HOME/.gnome"
  "$HOME/.dbus"
  "$HOME/.config"
  "$HOME/.kde"
  "$HOME/.pki"
  "$HOME/.ssh"
  "$HOME/.ansible"
  "$HOME/.npm"
  "$HOME/.jupyter"
  "$HOME/.vscode"
  "$HOME/.tmp"
  "$HOME/.temp"
)

# Inotifywait options
inotifywait_options="-m -r -e create -e delete -e move"

# Function to build the initial file index
build_file_index() {
    local find_command="find $dir_to_watch"
    for excl_dir in "${EXCLUDE_DIRS[@]}"; do
        find_command+=" -path '$excl_dir' -prune -o"
    done
    find_command+=" -type f -not -path '*/\.*' -print 2>/dev/null > $file_index"
    eval $find_command
}

# Function to build the initial directory index
build_dir_index() {
    local find_command="find $dir_to_watch"
    for excl_dir in "${EXCLUDE_DIRS[@]}"; do
        find_command+=" -path '$excl_dir' -prune -o"
    done
    find_command+=" -type d -not -path '*/\.*' -print 2>/dev/null > $dir_index"
    eval $find_command
}

# Function to build the initial hidden file index
build_hidden_file_index() {
    local find_command="find $dir_to_watch"
    for excl_dir in "${EXCLUDE_DIRS[@]}"; do
        find_command+=" -path '$excl_dir' -prune -o"
    done
    find_command+=" -type f -path '*/\.*' -print 2>/dev/null > $hidden_file_index"
    eval $find_command
}

# Function to build the initial hidden directory index
build_hidden_dir_index() {
    local find_command="find $dir_to_watch"
    for excl_dir in "${EXCLUDE_DIRS[@]}"; do
        find_command+=" -path '$excl_dir' -prune -o"
    done
    find_command+=" -type d -path '*/\.*' -print 2>/dev/null > $hidden_dir_index"
    eval $find_command
}

watch_changes() {
    inotifywait $inotifywait_options --format '%w%f %e' "$dir_to_watch" | while read -r line; do
        file=$(echo $line | cut -d ' ' -f 1)
        event=$(echo $line | cut -d ' ' -f 2-)
        echo "File $file has event $event"
        if [[ $event == *"CREATE"* ]]; then
            if [ -f "$file" ]; then
                if [[ $(basename $file) == .?* ]]; then
                    echo $file >> $hidden_file_index
                else
                    echo $file >> $file_index
                fi
            elif [ -d "$file" ]; then
                if [[ $(basename $file) == .?* ]]; then
                    echo $file >> $hidden_dir_index
                else
                    echo $file >> $dir_index
                fi
            fi
        elif [[ $event == *"DELETE"* ]]; then
            sed -i "\|$file|d" $file_index
            sed -i "\|$file|d" $dir_index
            sed -i "\|$file|d" $hidden_file_index
            sed -i "\|$file|d" $hidden_dir_index
        fi
    done
}

# Build initial indexes
build_file_index
build_dir_index
build_hidden_file_index
build_hidden_dir_index

# Watch for changes in files/directories
watch_changes
