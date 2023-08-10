#!/bin/bash

# Define directories to watch and index files
dir_to_watch=$HOME
file_index="$HOME/.cache/dmenu-utils/dmenu_file_browser_index"
dir_index="$HOME/.cache/dmenu-utils/dmenu_dir_browser_index"
hidden_file_index="$HOME/.cache/dmenu-utils/dmenu_hidden_file_browser_index"
hidden_dir_index="$HOME/.cache/dmenu-utils/dmenu_hidden_dir_browser_index"

create_directories_and_files() {
    # Create the cache directory if it doesn't exist
    if [ ! -d "$HOME/.cache/dmenu-utils/" ]; then
        mkdir -p "$HOME/.cache/dmenu-utils/"
    fi

    # Create the index files if they don't exist
    for index_file in "$HOME/.cache/dmenu-utils/dmenu_file_browser_index" "$HOME/.cache/dmenu-utils/dmenu_dir_browser_index" "$HOME/.cache/dmenu-utils/dmenu_hidden_file_browser_index" "$HOME/.cache/dmenu-utils/dmenu_hidden_dir_browser_index"; do
        if [ ! -f "$index_file" ]; then
            touch "$index_file"
        fi
    done
}

create_directories_and_files


# Check if required commands are available
for cmd in inotifywait; do
  if ! command -v $cmd &> /dev/null; then
    echo "error: $cmd could not be found. Please install $cmd."
    exit 1
  fi
done

# Define directories to exclude with $HOME
EXCLUDE_DIRS=(
  "$HOME/.cache"
  "$HOME/.local/lib"
  "$HOME/.local/share"
  "$HOME/.local/opt"
  "$HOME/.local/state"
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
  "$HOME/.zoom"
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
    local exclude_pattern=""
    for excl_dir in "${EXCLUDE_DIRS[@]}"; do
        exclude_pattern+="|$excl_dir"
    done
    exclude_pattern=${exclude_pattern#|} # Remove the leading |

    inotifywait $inotifywait_options --exclude "$exclude_pattern" --format '%w%f %e' "$dir_to_watch" | while read -r line; do
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
            echo "File $file was deleted"
            sed -i "\|$file|d" $file_index
            sed -i "\|$file|d" $dir_index
            sed -i "\|$file|d" $hidden_file_index
            sed -i "\|$file|d" $hidden_dir_index
        elif [[ $event == *"MOVED_FROM"* ]]; then
            echo "File $file was moved from"
            sed -i "\|$file|d" $file_index
            sed -i "\|$file|d" $dir_index
            sed -i "\|$file|d" $hidden_file_index
            sed -i "\|$file|d" $hidden_dir_index
        elif [[ $event == *"MOVED_TO"* ]]; then
            echo "File $file was moved to"
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
