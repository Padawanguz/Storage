#!/bin/bash
set -x
set -e
# Script name: dmenu file and directory browser
#
# This is a Bash script for navigating and managing file systems in a menu-driven interface using dmenu.
# The script supports a variety of operations on both files and directories, including copying, moving, deleting, renaming, archiving, and creating new files or folders.
# It also allows for bulk operations on multiple files at once.
#
# The script uses the following symbols for navigation and control:
# - "..": Navigate to the parent directory
# - "~": Navigate to the home directory
# - "@": Jump to a specified directory
# - "/": Toggle between the current directory view and find mode (search across all indexed files)
# - "#": Toggle between the current directory view and find mode (search across all indexed files)
# - "&": Toggle the visibility of hidden files
# - "?": Open a menu of operations that can be performed on the current directory
#
# In the operations menu (triggered by "?"), you can select from a variety of operations:
# - Copy, Move, Delete, Rename: Perform the selected operation on the current directory
# - Create New File, Create New Folder: Create a new file or directory in the current directory
# - Open Terminal Here, Open in File Manager: Open the current directory in a terminal or file manager
# - Archive: Compress the current directory into a file
# - Bulk Move, Bulk Copy, Bulk Delete: Perform the selected operation on multiple files at once
#
# When a file is selected (rather than a directory), a similar menu of file operations is displayed.
# These operations are performed on the selected file rather than the current directory.
#
# The script keeps an index of all files and directories for quick searching.
# The index is updated whenever a file or directory is created, deleted, or renamed.
#
# By default, hidden files (those beginning with a ".") are not shown or included in the index.
# You can toggle the visibility of hidden files with the "&" command.
#
# Note: This script uses the dmenu tool for its menu-driven interface.
# You will need to have dmenu installed on your system to use this script.
#
# This script can be used in conjunction with the `inotify-watch-index.sh` script.
#`inotify-watch-index.sh` uses the Linux kernel's inotify API to watch for file system changes in real-time.
# When a change is detected (such as a file or directory being created, modified, or deleted), `inotify-watch-index.sh` triggers an update to the index used by this dmenu file and directory browser.
# This allows the index to stay up-to-date without having to manually rebuild it, providing a seamless browsing experience.

dir=$HOME
show_hidden=false
find_view=false
file_index="$HOME/.cache/dmenu-utils/dmenu_file_browser_index"
dir_index="$HOME/.cache/dmenu-utils/dmenu_dir_browser_index"
hidden_file_index="$HOME/.cache/dmenu-utils/dmenu_hidden_file_browser_index"
hidden_dir_index="$HOME/.cache/dmenu-utils/dmenu_hidden_dir_browser_index"
WATCHDAEMON=true # Flag to indicate if the daemon is used to update the index
INDEX_UPDATED=false # Flag to indicate if the index has been updated, it must be always false at the beginning of the script
TERMINAL_COMMANDS=("st" "kitty" "rxvt" "sakura" "lilyterm" "roxterm" "termite" "Alacritty" "xterm") #Helps compatibility with different terminal emulators

create_directories_and_files() {
    # Create the cache directory if it doesn't exist
    if [ ! -d "$HOME/.cache/dmenu-utils/" ]; then
        mkdir -p "$HOME/.cache/dmenu-utils/"
    fi

    # Create the index files if they don't exist
    for index_file in \
        "$HOME/.cache/dmenu-utils/dmenu_file_browser_index" \
        "$HOME/.cache/dmenu-utils/dmenu_dir_browser_index" \
        "$HOME/.cache/dmenu-utils/dmenu_hidden_file_browser_index" \
        "$HOME/.cache/dmenu-utils/dmenu_hidden_dir_browser_index"; do
        if [ ! -f "$index_file" ]; then
            touch "$index_file"
        fi
    done
}

create_directories_and_files

# Check if required commands are available
for cmd in zip tar dmenu python3; do
  if ! command -v $cmd &> /dev/null; then
    echo "error: $cmd could not be found. Please install $cmd."
    exit 1
  fi
done

# Find the terminal emulator
get_terminal() {
  for cmd in "${TERMINAL_COMMANDS[@]}"; do
    terminal=$(command -v $cmd 2>/dev/null)
    if [ -n "$terminal" ]; then
      echo "$terminal"
      return
    fi
  done

  echo "No terminal emulator found. This script requires a terminal emulator to be installed."
  exit 1
}

terminal=$(get_terminal)

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

# Construct the find command for files only
find_command="find $HOME"
for excl_dir in "${EXCLUDE_DIRS[@]}"; do
  find_command+=" -path $excl_dir -prune -o"
done
find_command+=" -type f -print"

# Construct the find command for directories only
find_dir_command="find $HOME"
for excl_dir in "${EXCLUDE_DIRS[@]}"; do
  find_dir_command+=" -path $excl_dir -prune -o"
done
find_dir_command+=" -type d -print"

# Create the indexes if they don't exist
if [ ! -f "$file_index" ] || [ ! -f "$dir_index" ] || [ ! -f "$hidden_file_index" ] || [ ! -f "$hidden_dir_index" ]; then
    eval $find_command | grep -v '/\.' > $file_index
    eval $find_command > $hidden_file_index
    eval $find_dir_command | grep -v '/\.' > $dir_index
    eval $find_dir_command > $hidden_dir_index
    INDEX_UPDATED=true
fi

delete_current_folder() {
    if [ "$dir" == "$HOME" ]; then
        echo "Cannot delete the home directory."
        return
    fi
    confirm=$(echo -e "yes\nno" | dmenu -i -p "Confirm you want to delete folder $dir?")
    if [ "$confirm" == "yes" ]; then
        # Before deleting the directory, save its parent directory
        parent_dir=$(dirname "$dir")
        rm -r "$dir"
        # After deleting, change the current directory to the parent directory
        dir="$parent_dir"
        INDEX_UPDATED=true
    fi
}

move_current_dir() {
    dest=$(cat "$dir_index" | python3 -c "import sys; print(''.join(sorted(sys.stdin, key=len)))" | dmenu -i -l 20 -p "Move to: ")
    if [ -n "$dest" ]; then
        confirm=$(echo -e "yes\nno" | dmenu -i -p "Confirm you want to move $dir to $dest?")
        if [ "$confirm" == "yes" ]; then
            mv "$dir" "$dest"
            INDEX_UPDATED=true
            # Set the current directory to the parent directory
            dir=$(dirname "$dir")
        fi
    fi
}

copy_current_dir() {
    dest=$(cat "$dir_index" | python3 -c "import sys; print(''.join(sorted(sys.stdin, key=len)))" | dmenu -i -l 20 -p "Copy to: ")
    if [ -n "$dest" ]; then
        confirm=$(echo -e "yes\nno" | dmenu -i -p "Confirm you want to copy directory $dir to $dest?")
        if [ "$confirm" == "yes" ]; then
            cp -r "$dir" "$dest"
            INDEX_UPDATED=true
        fi
    fi
}

rename_current_dir() {
    new_name=$(echo -e "" | dmenu -i -p "New name")
    if [ -n "$new_name" ]; then
        confirm=$(echo -e "yes\nno" | dmenu -i -p "Confirm you want to rename directory $dir to $new_name?")
        if [ "$confirm" == "yes" ]; then
            mv "$dir" "$(dirname "$dir")/$new_name"
            INDEX_UPDATED=true
        fi
    fi
}

open_terminal_here() {
    $terminal -e bash -c "cd $dir; $SHELL" &
    exit 0
}

create_new_file() {
    file_count=$(seq 1 100 | tr '\n' '\0' | xargs -0 -n1 | dmenu -i -p "How many files?")
    if [ -n "$file_count" ]; then
        for ((i=1;i<=$file_count;i++)); do
            file_name=$(echo -e "" | dmenu -i -p "File name $i")
            if [ -z "$file_name" ]; then
                file_name="untitled($i)"
            fi
            touch "$dir/$file_name"
            INDEX_UPDATED=true
        done
    fi
}

create_new_folder() {
    folder_count=$(seq 1 100 | tr '\n' '\0' | xargs -0 -n1 | dmenu -i -p "How many folders?")
    if [ -n "$folder_count" ]; then
        for ((i=1;i<=$folder_count;i++)); do
            folder_name=$(echo -e "" | dmenu -i -p "Folder name $i")
            if [ -z "$folder_name" ]; then
                folder_name="untitled($i)"
            fi
            mkdir "$dir/$folder_name"
            INDEX_UPDATED=true
        done
    fi
}

archive() {
    archive_name=$(echo -e "" | dmenu -i -p "Archive name (without extension)")
    if [ -n "$archive_name" ]; then
        zip -r "$dir/$archive_name.zip" "$dir"
        INDEX_UPDATED=true
    fi
}

open_in_file_manager() {
    xdg-open "$dir"
    exit 0
}

get_files_for_operation() {
    # Generate the list of files in the current directory
    files=( "$dir"/* )
    file_count=${#files[@]}
    options=("*" $(seq 1 $file_count))

    # Prompt the user to select the number of files to operate on
    operation_count=$(printf '%s\n' "${options[@]}" | dmenu -i -p "How many files to $1?")

    if [ "$operation_count" == "*" ]; then
        operation_count=$file_count
        files_to_operate=("${files[@]}") # Add all files to files_to_operate
    else
        if [ -n "$operation_count" ]; then
            # Store the files to be operated on
            files_to_operate=()

            for ((i=1;i<=$operation_count;i++)); do
                # Prompt the user to select a file
                file=$(printf '%s\n' "${files[@]}" | dmenu -i -p "Select file $i to $1")

                # Store the original files array
                original_files=("${files[@]}")

                # Empty the files array
                files=()

                # Rebuild the files array excluding the selected file
                for file_item in "${original_files[@]}"; do
                    if [ "$file_item" != "$file" ]; then
                        files+=("$file_item")
                    fi
                done

                # Add the selected file to the list of files to operate on
                files_to_operate+=("$file")
            done
        fi
    fi

    echo "${files_to_operate[@]}"
}

bulk_delete() {
    # Get the files to delete
    files_to_delete=($(get_files_for_operation "delete"))

    # If no files were selected, return immediately
    if [ ${#files_to_delete[@]} -eq 0 ]; then
        return
    fi

    # Get the filenames from the full paths
    filenames_to_delete=()
    for fullpath in "${files_to_delete[@]}"; do
        filenames_to_delete+=("$(basename "$fullpath")")
    done

    # Limit the number of filenames displayed
    display_limit=5
    if [ ${#filenames_to_delete[@]} -gt $display_limit ]; then
        files_to_delete_string=$(printf ' %s' "${filenames_to_delete[@]:0:$display_limit}")
        files_to_delete_string="${files_to_delete_string:1} ... and $((${#filenames_to_delete[@]} - $display_limit)) more"
    else
        files_to_delete_string=$(printf ' %s' "${filenames_to_delete[@]}")
        files_to_delete_string=${files_to_delete_string:1}
    fi

    # Confirm the deletion
    confirm=$(echo -e "yes\nno" | dmenu -i -p "Confirm you want to delete these files? $files_to_delete_string")
    if [ "$confirm" == "yes" ]; then
        rm -r "${files_to_delete[@]}"
        INDEX_UPDATED=true
    fi
}

bulk_move() {
    # Get the files to delete
    files_to_move=($(get_files_for_operation "move"))

    # If no files were selected, return immediately
    if [ ${#files_to_move[@]} -eq 0 ]; then
        return
    fi

    # Get the destination directory
    dest=$(cat "$dir_index" | python3 -c "import sys; print(''.join(sorted(sys.stdin, key=len)))" | dmenu -i -l 20 -p "Move to: ")

    if [ -n "$dest" ]; then
        # Get the filenames from the full paths
        filenames_to_move=()
        for fullpath in "${files_to_move[@]}"; do
            filenames_to_move+=("$(basename "$fullpath")")
        done

        # Limit the number of filenames displayed
        display_limit=5
        if [ ${#filenames_to_move[@]} -gt $display_limit ]; then
            files_to_move_string=$(printf ' %s' "${filenames_to_move[@]:0:$display_limit}")
            files_to_move_string="${files_to_move_string:1} ... and $((${#filenames_to_move[@]} - $display_limit)) more"
        else
            files_to_move_string=$(printf ' %s' "${filenames_to_move[@]}")
            files_to_move_string=${files_to_move_string:1}
        fi

        # Confirm the move
        confirm=$(echo -e "yes\nno" | dmenu -i -p "Confirm you want to move these files? $files_to_move_string to $dest")
        if [ "$confirm" == "yes" ]; then
            mv "${files_to_move[@]}" "$dest"
            INDEX_UPDATED=true
        fi
    fi
}


bulk_copy() {
    # Get the files to copy
    files_to_copy=($(get_files_for_operation "copy"))

    # If no files were selected, return immediately
    if [ ${#files_to_copy[@]} -eq 0 ]; then
        return
    fi

    # Get the destination directory
    dest=$(cat "$dir_index" | python3 -c "import sys; print(''.join(sorted(sys.stdin, key=len)))" | dmenu -i -l 20 -p "Copy to: ")

    if [ -n "$dest" ]; then
        # Get the filenames from the full paths
        filenames_to_copy=()
        for fullpath in "${files_to_copy[@]}"; do
            filenames_to_copy+=("$(basename "$fullpath")")
        done

        # Limit the number of filenames displayed
        display_limit=5
        if [ ${#filenames_to_copy[@]} -gt $display_limit ]; then
            files_to_copy_string=$(printf ' %s' "${filenames_to_copy[@]:0:$display_limit}")
            files_to_copy_string="${files_to_copy_string:1} ... and $((${#filenames_to_copy[@]} - $display_limit)) more"
        else
            files_to_copy_string=$(printf ' %s' "${filenames_to_copy[@]}")
            files_to_copy_string=${files_to_copy_string:1}
        fi

        # Confirm the copy
        confirm=$(echo -e "yes\nno" | dmenu -i -p "Confirm you want to copy these files? $files_to_copy_string to $dest")
        if [ "$confirm" == "yes" ]; then
            { cp -r "${files_to_copy[@]}" "$dest" && INDEX_UPDATED=true; } &
        fi
    fi
}

open_file() {
    xdg-open "$path"
}

rename_file() {
    new_name=$(echo -e "" | dmenu -i -p "New name")
    if [ -n "$new_name" ]; then
        confirm=$(echo -e "yes\nno" | dmenu -i -p "Confirm you want to rename file $path to $new_name?")
        if [ "$confirm" == "yes" ]; then
            mv "$path" "$(dirname "$path")/$new_name"
            INDEX_UPDATED=true
        fi
    fi
}

delete_file() {
    confirm=$(echo -e "yes\nno" | dmenu -i -p "Confirm you want to delete file $path?")
    if [ "$confirm" == "yes" ]; then
        rm -r "$path"
        INDEX_UPDATED=true
    fi
}

copy_file() {
    dest=$(cat "$dir_index" | python3 -c "import sys; print(''.join(sorted(sys.stdin, key=len)))" | dmenu -i -l 20 -p "Copy to: ")
    if [ -n "$dest" ]; then
        confirm=$(echo -e "yes\nno" | dmenu -i -p "Confirm you want to copy file $path to $dest?")
        if [ "$confirm" == "yes" ]; then
            { cp "$path" "$dest" && INDEX_UPDATED=true; } &
        fi
    fi
}

move_file() {
    dest=$(cat "$dir_index" | python3 -c "import sys; print(''.join(sorted(sys.stdin, key=len)))" | dmenu -i -l 20 -p "Move to: ")
    if [ -n "$dest" ]; then
        confirm=$(echo -e "yes\nno" | dmenu -i -p "Confirm you want to move file $path to $dest?")
        if [ "$confirm" == "yes" ]; then
            mv "$path" "$dest"
            INDEX_UPDATED=true
        fi
    fi
}

compress_file() {
    echo "Compress operation selected"
    archive_name=$(echo -e "" | dmenu -i -p "Archive name (without extension)")
    echo "Archive name: $archive_name"
    if [ -n "$archive_name" ]; then
        archive_format=$(echo -e "tar.gz\nzip\ntar.bz2\ntar.xz\n7z" | dmenu -i -p "Choose compression format")
        echo "Archive format: $archive_format"

        if [ "$archive_format" == "tar.gz" ]; then
            command="tar -czf"
            extension=".tar.gz"
        elif [ "$archive_format" == "zip" ]; then
            command="zip -j"
            extension=".zip"
        elif [ "$archive_format" == "tar.bz2" ]; then
            command="tar -cjf"
            extension=".tar.bz2"
        elif [ "$archive_format" == "tar.xz" ]; then
            command="tar -cJf"
            extension=".tar.xz"
        elif [ "$archive_format" == "7z" ]; then
            command="7z a"
            extension=".7z"
        fi

        confirm=$(echo -e "yes\nno" | dmenu -i -p "Confirm you want to compress file $path to $archive_name$extension?")
        echo "User confirmed: $confirm"
        if [ "$confirm" == "yes" ]; then
            echo "Running: $command \"/tmp/$archive_name$extension\" \"$path\""
            ($command "/tmp/$archive_name$extension" "$path" && mv "/tmp/$archive_name$extension" "$dir/$archive_name$extension" && INDEX_UPDATED=true) &
        fi
    fi
}

# Function to check if a file is a compressed archive
is_compressed_archive() {
    local filename=$1
    file_type=$(file --mime-type -b "$filename")
    case "$file_type" in
        application/gzip|application/x-bzip2|application/x-xz|application/zip|application/x-rar|application/x-7z-compressed)
            return 0
            ;;
        *)
            return 1
            ;;
    esac
}

# Function to extract a compressed archive
extract_archive() {
    local archive=$1
    local dest_dir=$2
    local success_msg="Extraction of $archive completed successfully."
    local fail_msg="Extraction of $archive failed."

    case "$archive" in
        *.tar.gz|*.tgz|*.tar|*.tar.bz2|*.tbz2|*.tar.xz|*.txz)
            (tar xf "$archive" -C "$dest_dir" && echo "$success_msg" && INDEX_UPDATED=true) || echo "$fail_msg" &
            ;;
        *.zip)
            (unzip "$archive" -d "$dest_dir" && echo "$success_msg" && INDEX_UPDATED=true) || echo "$fail_msg" &
            ;;
        *.rar)
            (unrar x "$archive" "$dest_dir" && echo "$success_msg" && INDEX_UPDATED=true) || echo "$fail_msg" &
            ;;
        *.7z)
            (7z x "$archive" -o"$dest_dir" && echo "$success_msg" && INDEX_UPDATED=true) || echo "$fail_msg" &
            ;;
        *)
            echo "Unsupported archive format: $archive"
            ;;
    esac
}

file_operations() {
    local path=$1

    if is_compressed_archive "$path"; then
        operation=$(echo -e "Open\nRename\nDelete\nCopy\nMove\nExtract" | dmenu -i -p "$path")
    else
        operation=$(echo -e "Open\nRename\nDelete\nCopy\nMove\nCompress" | dmenu -i -p "$path")
    fi

    if [ "$operation" == "Open" ]; then
        open_file "$path"
    elif [ "$operation" == "Rename" ]; then
        rename_file "$path"
    elif [ "$operation" == "Delete" ]; then
        delete_file "$path"
    elif [ "$operation" == "Copy" ]; then
        copy_file "$path"
    elif [ "$operation" == "Move" ]; then
        move_file "$path"
    elif [ "$operation" == "Compress" ]; then
        compress_file "$path"
    elif [ "$operation" == "Extract" ]; then
        dest=$(cat "$dir_index" | python3 -c "import sys; print(''.join(sorted(sys.stdin, key=len)))" | dmenu -i -l 20 -p "Extract to: ")
        if [ -n "$dest" ]; then
            confirm=$(echo -e "yes\nno" | dmenu -i -p "Confirm you want to extract archive $path to $dest?")
            if [ "$confirm" == "yes" ]; then
                extract_archive "$path" "$dest"
                INDEX_UPDATED=true
            fi
        fi
    fi
}

# Loop indefinitely
while true; do
    # Initialize an empty path
    path=""

    # Generate the list of items based on the current mode
    list=""
    # If find_view is true, then we are in find mode
    if $find_view ; then
        # Show hidden files if show_hidden is true
        if $show_hidden ; then
            list=$(cat $hidden_file_index | python3 -c "import sys; print(''.join(sorted(sys.stdin, key=len)))")
        else
            # Otherwise, don't show hidden files
            list=$(cat $file_index | python3 -c "import sys; print(''.join(sorted(sys.stdin, key=len)))")
        fi
    else
        # If not in find mode, show directory contents
        # Show hidden files if show_hidden is true
        if $show_hidden ; then
            list=$(ls -A --group-directories-first "$dir")
        else
            # Otherwise, don't show hidden files
            list=$(ls --group-directories-first "$dir")
        fi
    fi

    # Get the user's selection
    # Generate the display text for the toggle option based on the current view
    if $find_view; then
        toggle_option="#"
    else
        toggle_option="/"
    fi

    # Include the toggle option in the list passed to dmenu
    # If the list is not empty, include it; otherwise, do not include it
    if [ -z "$list" ]; then
        options="@\n..\n~\n$toggle_option\n&\n?"
    else
        options="@\n..\n~\n$toggle_option\n&\n?\n$list"
    fi
    selection=$(echo -e "$options" | dmenu -i -l 20 -p "$dir")

    # If the user didn't make a selection, check the current directory
    if [ -z "$selection" ]; then
        if [ "$dir" != "$HOME" ]; then
            dir=$HOME
            continue
        else
            exit 0
        fi
    fi

    # Navigate to the parent directory
    if [ "$selection" == ".." ]; then
        dir=$(dirname "$dir")
        continue
    fi

    # Navigate to the home directory
    if [ "$selection" == "~" ]; then
        dir=$HOME
        continue
    fi

    # Jump to a directory
    if [ "$selection" == "@" ]; then
        dir_jump=$(cat "$dir_index" | python3 -c "import sys; print(''.join(sorted(sys.stdin, key=len)))" | dmenu -i -l 20 -p "Jump to: ")
        # If a directory was selected, jump to that directory
        if [ -n "$dir_jump" ]; then
            dir="$dir_jump"
            find_view=false
        fi
        continue
    fi

    if [ "$selection" == "$toggle_option" ]; then
        if $find_view ; then
            find_view=false
        else
            find_view=true
        fi
        continue
    fi

    # Toggle the visibility of hidden files
    if [ "$selection" == "&" ]; then
        # If hidden files are currently visible, hide them
        if $show_hidden ; then
            show_hidden=false
        else
            # If hidden files are currently hidden, show them
            show_hidden=true
        fi
        continue
    fi

    # Handle operations on the current directory
    if [ "$selection" == "?" ]; then
        folder_operation=$(echo -e "Copy\nMove\nDelete\nRename\nCreate New File\nCreate New Folder\nOpen Terminal Here\nOpen in File Manager\nArchive\nBulk Move\nBulk Copy\nBulk Delete" | dmenu -i -p "$dir")
        # Call the appropriate function based on the selected operation
        # Each function handles a different operation
        if [ "$folder_operation" == "Delete" ]; then
          delete_current_folder
        elif [ "$folder_operation" == "Bulk Delete" ]; then
          bulk_delete
        elif [ "$folder_operation" == "Bulk Move" ]; then
          bulk_move
        elif [ "$folder_operation" == "Bulk Copy" ]; then
          bulk_copy
        elif [ "$folder_operation" == "Open Terminal Here" ]; then
          open_terminal_here
        elif [ "$folder_operation" == "Create New File" ]; then
          create_new_file
        elif [ "$folder_operation" == "Create New Folder" ]; then
          create_new_folder
        elif [ "$folder_operation" == "Archive" ]; then
          archive
        elif [ "$folder_operation" == "Open in File Manager" ]; then
          open_in_file_manager
        elif [ "$folder_operation" == "Copy" ]; then
          copy_current_dir
        elif [ "$folder_operation" == "Move" ]; then
          move_current_dir
        elif [ "$folder_operation" == "Rename" ]; then
          rename_current_dir
        fi
        continue
    fi

    # If in find mode, path is the selection
    # Otherwise, the path is the current directory plus the selection
    if $find_view ; then
        path="$selection"
    else
        path="$dir/$selection"
    fi

    # If the path is a directory, navigate to that directory
    if [ -d "$path" ]; then
        dir=$path
    # If the path is a file, handle operations on that file
    elif [ -f "$path" ]; then
      file_operations "$path"
    fi

    # Rebuild the index if a file or directory has been renamed or deleted
    if [ "$WATCHDAEMON" == "false" ]; then
        if $INDEX_UPDATED ; then
            eval $find_command | grep -v '/\.' > $file_index
            eval $find_command > $hidden_file_index
            eval $find_dir_command | grep -v '/\.' > $dir_index
            eval $find_dir_command > $hidden_dir_index
            INDEX_UPDATED=false
        fi
    fi

done
