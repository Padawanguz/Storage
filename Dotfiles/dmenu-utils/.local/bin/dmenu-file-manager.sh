#!/bin/bash
set -x
set -e

# Script name: dmenu file and directory browser
#
# This script provides an interactive file and directory browser using dmenu. It maintains an index of files and directories, excluding certain directories defined in the EXCLUDE_DIRS variable.
# It allows users to navigate through their file system, open files, and perform several operations such as renaming, deleting, copying, moving, and compressing files.
#
# Dependencies:
# - find: Used to generate an index of files and directories.
# - grep: Used to filter out hidden files and directories from the index.
# - ls: Used to list files and directories in the current directory.
# - cat: Used to read the index files.
# - touch: Used to create new files.
# - mkdir: Used to create new directories.
# - zip: Used to compress files.
# - xdg-open: Used to open files and directories with the default applications.
# - rm: Used to delete files.
# - cp: Used to copy files.
# - mv: Used to move and rename files.
# - tar: Used to compress files.
# - dmenu: Used to create an interactive menu.
#
# This script can be used in conjunction with the `inotify-watch-index.sh` script. `inotify-watch-index.sh` uses the Linux kernel's inotify API to watch for file system changes in real-time. When a change is detected (such as a file or directory being created, modified, or deleted), `inotify-watch-index.sh` triggers an update to the index used by this dmenu file and directory browser. This allows the index to stay up-to-date without having to manually rebuild it, providing a seamless browsing experience.
#
# To use this script, simply run it from a terminal. Use the dmenu interface to navigate through your file system and perform operations on files and directories.
#
# The '@' option allows you to jump to any directory indexed, and the 'Toggle View' and 'Toggle Hidden' options allow you to switch between different views.
#

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
    for index_file in "$HOME/.cache/dmenu-utils/dmenu_file_browser_index" "$HOME/.cache/dmenu-utils/dmenu_dir_browser_index" "$HOME/.cache/dmenu-utils/dmenu_hidden_file_browser_index" "$HOME/.cache/dmenu-utils/dmenu_hidden_dir_browser_index"; do
        if [ ! -f "$index_file" ]; then
            touch "$index_file"
        fi
    done
}

create_directories_and_files

# Check if required commands are available
for cmd in zip tar; do
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

while true; do
    path=""

    # Generate the list of items based on the current mode
    list=""
    if $find_view ; then
        if $show_hidden ; then
            list=$(cat $hidden_file_index | python3 -c "import sys; print(''.join(sorted(sys.stdin, key=len)))")
        else
            list=$(cat $file_index | python3 -c "import sys; print(''.join(sorted(sys.stdin, key=len)))")
        fi
    else
        if $show_hidden ; then
            list=$(ls -A --group-directories-first "$dir")
        else
            list=$(ls --group-directories-first "$dir")
        fi
    fi
    selection=$(echo -e "@\n..\n~\nToggle View\nToggle Hidden\n- - -\n$list" | dmenu -i -l 20 -p "$dir")

    if [ -z "$selection" ]; then
        exit 0
    fi

    if [ "$selection" == ".." ]; then
        dir=$(dirname "$dir")
        continue
    fi

    if [ "$selection" == "~" ]; then
        dir=$HOME
        continue
    fi

    if [ "$selection" == "@" ]; then
        dir_jump=$(cat "$dir_index" | python3 -c "import sys; print(''.join(sorted(sys.stdin, key=len)))" | dmenu -i -l 20 -p "Jump to: ")
        if [ -n "$dir_jump" ]; then
            dir="$dir_jump"
            find_view=false
        fi
        continue
    fi

    if [ "$selection" == "Toggle View" ]; then
        if $find_view ; then
            find_view=false
        else
            find_view=true
        fi
        continue
    fi

    if [ "$selection" == "Toggle Hidden" ]; then
        if $show_hidden ; then
            show_hidden=false
        else
            show_hidden=true
        fi
        continue
    fi

    if [ "$selection" == "- - -" ]; then
        folder_operation=$(echo -e "Open Terminal Here\nCreate New File\nCreate New Folder\nArchive\nOpen in File Manager\nDelete Current Folder\nBulk Copy\nBulk Move\nBulk Delete" | dmenu -i -p "$dir")
        if [ "$folder_operation" == "Delete Current Folder" ]; then
            if [ "$dir" == "$HOME" ]; then
                echo "Cannot delete the home directory."
                continue
            fi
            confirm=$(echo -e "yes\nno" | dmenu -i -p "Confirm you want to delete folder $dir?")
            if [ "$confirm" == "yes" ]; then
                rm -r "$dir"
                dir=$HOME
                INDEX_UPDATED=true
            fi
        elif [ "$folder_operation" == "Open Terminal Here" ]; then
            $terminal -e bash -c "cd $dir; $SHELL" &
            exit 0
        elif [ "$folder_operation" == "Create New File" ]; then
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
        elif [ "$folder_operation" == "Bulk Delete" ]; then
            # Generate the list of files in the current directory
            files=( $(ls -1 -v "$dir"/*) )
            file_count=${#files[@]}
            options=("*" $(seq 1 $file_count))

            # Prompt the user to select the number of files to delete
            delete_count=$(printf '%s\n' "${options[@]}" | dmenu -i -p "How many files to delete?")

            if [ "$delete_count" == "*" ]; then
                delete_count=$file_count
                files_to_delete=("${files[@]}") # Add all files to files_to_delete
            else
                if [ -n "$delete_count" ]; then
                    # Store the files to be deleted
                    files_to_delete=()

                    for ((i=1;i<=$delete_count;i++)); do
                        # Prompt the user to select a file
                        file=$(printf '%s\n' "${files[@]}" | dmenu -i -p "Select file $i to delete")

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

                        # Add the selected file to the list of files to delete
                        files_to_delete+=("$file")
                    done
                fi
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
            confirm=$(echo -e "yes\nno" | dmenu -i -p "Confirm you want to delete these files?$files_to_delete_string")
            if [ "$confirm" == "yes" ]; then
                rm -r "${files_to_delete[@]}"
                INDEX_UPDATED=true
            fi


        elif [ "$folder_operation" == "Bulk Move" ]; then
            # Generate the list of files in the current directory
            files=( $(ls -1 -v "$dir"/*) )
            file_count=${#files[@]}
            options=("*" $(seq 1 $file_count))

            # Prompt the user to select the number of files to move
            move_count=$(printf '%s\n' "${options[@]}" | dmenu -i -p "How many files to move?")

            if [ "$move_count" == "*" ]; then
                move_count=$file_count
                files_to_move=("${files[@]}") # Add all files to files_to_move
            else
                if [ -n "$move_count" ]; then
                    # Store the files to be moved
                    files_to_move=()

                    for ((i=1;i<=$move_count;i++)); do
                        # Prompt the user to select a file
                        file=$(printf '%s\n' "${files[@]}" | dmenu -i -p "Select file $i to move")

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

                        # Add the selected file to the list of files to move
                        files_to_move+=("$file")
                    done
                fi
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
                confirm=$(echo -e "yes\nno" | dmenu -i -p "Confirm you want to move these files?$files_to_move_string to $dest")
                if [ "$confirm" == "yes" ]; then
                    mv "${files_to_move[@]}" "$dest"
                    INDEX_UPDATED=true
                fi
            fi

        elif [ "$folder_operation" == "Bulk Copy" ]; then
            # Generate the list of files in the current directory
            files=( $(ls -1 -v "$dir"/*) )
            file_count=${#files[@]}
            options=("*" $(seq 1 $file_count))

        # Prompt the user to select the number of files to copy
        copy_count=$(printf '%s\n' "${options[@]}" | dmenu -i -p "How many files to copy?")

        if [ "$copy_count" == "*" ]; then
            copy_count=$file_count
            files_to_copy=("${files[@]}") # Add all files to files_to_copy
        else
            if [ -n "$copy_count" ]; then
                # Store the files to be copied
                files_to_copy=()

                for ((i=1;i<=$copy_count;i++)); do
                    # Prompt the user to select a file
                    file=$(printf '%s\n' "${files[@]}" | dmenu -i -p "Select file $i to copy")

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

                    # Add the selected file to the list of files to copy
                    files_to_copy+=("$file")
                done
            fi
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
            confirm=$(echo -e "yes\nno" | dmenu -i -p "Confirm you want to copy these files?$files_to_copy_string to $dest")
            if [ "$confirm" == "yes" ]; then
                cp -r "${files_to_copy[@]}" "$dest"
                INDEX_UPDATED=true
            fi
        fi

        elif [ "$folder_operation" == "Create New Folder" ]; then
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
        elif [ "$folder_operation" == "Archive" ]; then
            archive_name=$(echo -e "" | dmenu -i -p "Archive name (without extension)")
            if [ -n "$archive_name" ]; then
                zip -r "$dir/$archive_name.zip" "$dir"
                INDEX_UPDATED=true
            fi
        elif [ "$folder_operation" == "Open in File Manager" ]; then
            xdg-open "$dir"
            exit 0
        fi

        continue
    fi

    if $find_view ; then
        path="$selection"
    else
        path="$dir/$selection"
    fi

    if [ -d "$path" ]; then
        dir=$path
    elif [ -f "$path" ]; then
        operation=$(echo -e "Open\nRename\nDelete\nCopy\nMove\nCompress" | dmenu -i -p "$path")
        if [ "$operation" == "Open" ]; then
            xdg-open "$path"
        elif [ "$operation" == "Rename" ]; then
            new_name=$(echo -e "" | dmenu -i -p "New name")
            if [ -n "$new_name" ]; then
                confirm=$(echo -e "yes\nno" | dmenu -i -p "Confirm you want to rename file $path to $new_name?")
                if [ "$confirm" == "yes" ]; then
                    mv "$path" "$(dirname "$path")/$new_name"
                    INDEX_UPDATED=true
                fi
            fi
        elif [ "$operation" == "Delete" ]; then
            confirm=$(echo -e "yes\nno" | dmenu -i -p "Confirm you want to delete file $path?")
            if [ "$confirm" == "yes" ]; then
                rm -r "$path"
                INDEX_UPDATED=true
            fi
        elif [ "$operation" == "Copy" ]; then
            dest=$(cat "$dir_index" | python3 -c "import sys; print(''.join(sorted(sys.stdin, key=len)))" | dmenu -i -l 20 -p "Copy to: ")
            if [ -n "$dest" ]; then
                confirm=$(echo -e "yes\nno" | dmenu -i -p "Confirm you want to copy file $path to $dest?")
                if [ "$confirm" == "yes" ]; then
                    cp "$path" "$dest"
                    INDEX_UPDATED=true
                fi
            fi
        elif [ "$operation" == "Move" ]; then
            dest=$(cat "$dir_index" | python3 -c "import sys; print(''.join(sorted(sys.stdin, key=len)))" | dmenu -i -l 20 -p "Move to: ")
            if [ -n "$dest" ]; then
                confirm=$(echo -e "yes\nno" | dmenu -i -p "Confirm you want to move file $path to $dest?")
                if [ "$confirm" == "yes" ]; then
                    mv "$path" "$dest"
                    INDEX_UPDATED=true
                fi
            fi
        elif [ "$operation" == "Compress" ]; then
            echo "Compress operation selected"
            archive_name=$(echo -e "" | dmenu -i -p "Archive name (without extension)")
            echo "Archive name: $archive_name"
            if [ -n "$archive_name" ]; then
                archive_format=$(echo -e "tar.gz\nzip" | dmenu -i -p "Choose compression format")
                echo "Archive format: $archive_format"
                if [ "$archive_format" == "tar.gz" ]; then
                    confirm=$(echo -e "yes\nno" | dmenu -i -p "Confirm you want to compress file $path to $archive_name.tar.gz?")
                    echo "User confirmed: $confirm"
                    if [ "$confirm" == "yes" ]; then
                        echo "Running: tar -czf \"$dir/$archive_name.tar.gz\" -C \"$(dirname "$path")\" \"$(basename "$path")\""
                        tar -czf "$dir/$archive_name.tar.gz" -C "$(dirname "$path")" "$(basename "$path")"
                        echo "tar command finished with status: $?"
                        INDEX_UPDATED=true
                    fi
                elif [ "$archive_format" == "zip" ]; then
                    confirm=$(echo -e "yes\nno" | dmenu -i -p "Confirm you want to compress file $path to $archive_name.zip?")
                    echo "User confirmed: $confirm"
                    if [ "$confirm" == "yes" ]; then
                        echo "Running: zip -j \"$dir/$archive_name.zip\" \"$path\""
                        zip -j "$dir/$archive_name.zip" "$path"
                        echo "zip command finished with status: $?"
                        INDEX_UPDATED=true
                    fi
                fi
            fi
        fi
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
