#!/bin/bash

dir=$HOME
show_hidden=false
find_view=false
file_index="$HOME/.cache/dmenu-utilities/dmenu_file_browser_index"
dir_index="$HOME/.cache/dmenu-utilities/dmenu_dir_browser_index"
hidden_file_index="$HOME/.cache/dmenu-utilities/dmenu_hidden_file_browser_index"
hidden_dir_index="$HOME/.cache/dmenu-utilities/dmenu_hidden_dir_browser_index"
WATCHDAEMON=true # Flag to indicate if the daemon is used to update the index
INDEX_UPDATED=false # Flag to indicate if the index has been updated, it must be always false at the beginning of the script
TERMINAL_COMMANDS=("st" "kitty" "rxvt" "sakura" "lilyterm" "roxterm" "termite" "Alacritty" "xterm") #Helps compatibility with different terminal emulators

# Check if required commands are available
for cmd in pacman auracle dmenu makepkg; do
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
        folder_operation=$(echo -e "Open Terminal Here\nCreate New File\nCreate New Folder\nArchive\nOpen in File Manager" | dmenu -i -p "$dir")
        if [ "$folder_operation" == "Open Terminal Here" ]; then
            $terminal -e bash -c "cd $dir; $SHELL" &
            exit 0
        elif [ "$folder_operation" == "Create New File" ]; then
            file_name=$(echo -e "" | dmenu -i -p "File name")
            if [ -n "$file_name" ]; then
                touch "$dir/$file_name"
                INDEX_UPDATED=true
            fi
        elif [ "$folder_operation" == "Create New Folder" ]; then
            folder_name=$(echo -e "" | dmenu -i -p "Folder name")
            if [ -n "$folder_name" ]; then
                mkdir "$dir/$folder_name"
                INDEX_UPDATED=true
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
