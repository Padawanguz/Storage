#!/bin/bash

# Description:
# This script provides a user-friendly interface for managing packages on an Arch Linux system.
# It utilizes dmenu for user interaction, providing options to install, remove, update, and downgrade packages,
# as well as clear the package cache and remove orphan packages. It supports both official repository packages
# and AUR packages.

# Dependencies:
# The script relies on the following tools: pacman, auracle, dmenu, and makepkg.
# Pacman is the package manager for Arch Linux and is used to handle official repository packages.
# Auracle is a command line tool used for interacting with the Arch User Repository (AUR),
# and is used by this script to handle AUR packages. Dmenu is a fast and lightweight dynamic menu for X,
# which is used to interact with the user. Makepkg is a script to automate the building of packages.

# Note:
# Make sure all dependencies are installed and that you have the appropriate permissions
# to install, remove, and update packages on your system.

# Define constants
AURACLE_CACHE_DIR="$HOME/.auracle"
INDEX_DIR="$HOME/.cache/dmenu-utils"
TERMINAL_COMMANDS=("st" "kitty" "rxvt" "sakura" "lilyterm" "roxterm" "termite" "Alacritty" "xterm")

# Check if required commands are available
for cmd in pacman auracle dmenu makepkg; do
  if ! command -v $cmd &> /dev/null; then
    echo "error: $cmd could not be found. Please install $cmd."
    exit 1
  fi
done

# check if index directory exists
if [ ! -d "$INDEX_DIR" ]; then
  mkdir "$INDER_DIR" || { echo "Error: Failed to create directory '$INDEX_DIR'"; exit 1; }
fi

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

display_info() {
  message=$1
  echo -e "$message"
}

confirm_action() {
  message=$1
  echo -e "$message"
  read -p "Continue? (Y/n): " response
  [[ $response =~ ^[Yy]$ || $response == "" ]]
}

handle_aur_package() {
  package=$1
  initial_dir=$(pwd)
  mkdir -p "$HOME/.auracle/"
  cd "$HOME/.auracle/"
  if [ -d "$package/.git" ]; then
    cd "$package"
    git pull
  else
    rm -rf "$package"
    auracle download "$package"
    cd "$package"
  fi
  read -p "Do you want to view the PKGBUILD for $package? (y/N): " view_pkgbuild
  if [[ $view_pkgbuild =~ ^[Yy]$ ]]; then
    cat PKGBUILD
  fi
  read -p "Do you want to continue installing this package? (Y/n): " cont
  if [[ $cont =~ ^[Nn]$ ]]; then
    echo "Skipping $package"
  else
    makepkg -si
  fi
  cd "$initial_dir"
}

list_aur_packages() {
    temp_file=$(mktemp)
    curl -s -o "$temp_file" https://aur.archlinux.org/packages.gz
    gzip -dc "$temp_file" | sed '1d'
    rm "$temp_file"
}

update_aur_packages() {
  outdated_packages=$(auracle outdated | awk '{print $1}')
  if [ -z "$outdated_packages" ]; then
    echo "No AUR packages to update."
  else
    for package in $outdated_packages; do
      display_info "Updating AUR package: $package"
      handle_aur_package "$package"
    done
  fi
}

clean_auracle_cache() {
  read -p "This will loop over all directories in the AUR cache and delete any that have not been modified in the last 30 days. Continue? (Y/n): " cont
  if [[ $cont =~ ^[Nn]$ ]]; then
    echo "Skipping AUR cache clean."
  else
    for dir in "$AURACLE_CACHE_DIR"/*; do
      if [ "$(( $(date +%s) - $(stat -c %Y "$dir") ))" -gt 2592000 ]; then
        echo "Removing $dir"
        rm -rf "$dir"
      fi
    done
  fi
}

export -f confirm_action
export -f clean_auracle_cache
export -f display_info
export -f handle_aur_package
export -f update_aur_packages

# Install a package
install_package() {
  selected_package=$(dmenu -i -p "Install: " < "$index_file")
  if [ -n "$selected_package" ]; then
    if pacman -Si "$selected_package" >/dev/null 2>&1; then
      package_info=$(pacman -Si "$selected_package")
      $terminal -e bash -c "
        $(declare -f display_info)
        selected_package='$selected_package'
        package_info='$package_info'
        display_info '$package_info'
        sudo pacman -S \$selected_package
        echo 'Press ENTER to exit...'
        read
      "
    elif auracle info "$selected_package" >/dev/null 2>&1; then
      package_info=$(auracle info "$selected_package")
      $terminal -e bash -c "
        $(declare -f display_info)
        $(declare -f handle_aur_package)
        selected_package='$selected_package'
        package_info='$package_info'
        display_info '$package_info'
        handle_aur_package \$selected_package
        echo 'Press ENTER to exit...'
        read
      "
    else
      echo "Package $selected_package not found."
    fi
  fi
}

# Remove a package
remove_package() {
  selected_package=$(pacman -Qq | dmenu -i -p "Remove: ")
  if [ -n "$selected_package" ]; then
    package_info=$(pacman -Qi "$selected_package")
    $terminal -e bash -c "
      $(declare -f display_info)
      selected_package='$selected_package'
      package_info='$package_info'
      display_info '$package_info'
      sudo pacman -Rns \$selected_package
      echo 'Press ENTER to exit...'
      read
    "
  fi
}

# Update all packages
update_packages() {
  $terminal -e bash -c "
    $(declare -f display_info)
    $(declare -f confirm_action)
    $(declare -f update_aur_packages)
    if confirm_action 'This will update all packages from the official repositories.'; then
      sudo pacman -Syu
      if confirm_action 'Do you want to update AUR packages as well?'; then
        update_aur_packages
      fi
    fi
    echo 'Press ENTER to exit...'
    read
  "
}

# Remove orphan packages
remove_orphan_packages() {
  $terminal -e bash -c "
    orphans=\$(pacman -Qdtq)
    if [ -n \"\$orphans\" ]; then
      echo \"Removing orphans: \$orphans\"
      sudo pacman -Rns \$orphans
    else
      echo \"No orphans to remove.\"
    fi
    echo 'Press ENTER to exit...'
    read
  "
}

# Clear package cache
clear_package_cache() {
  $terminal -e bash -c "
    $(declare -f display_info)
    $(declare -f confirm_action)
    $(declare -f clean_auracle_cache)
    if confirm_action 'This will remove all but the three most recent versions of each package in pacman's cache and packages older than 30 days in the AUR cache.'; then
      sudo paccache -r
      clean_auracle_cache
    fi
    echo 'Press ENTER to exit...'
    read
  "
}

downgrade_package() {
  package=$(dmenu -i -p "Downgrade: " < "$index_file")
  if [ -z "$package" ]; then
    echo "No package selected."
    return
  fi

  if pacman -Si $package >/dev/null 2>&1; then
    versions=$(unset WGETRC; wget -q https://archive.archlinux.org/packages/${package:0:1}/$package/ -O - | grep -oP 'href="\K[^"]*pkg.tar.(xz|zst)' | sed 's/.pkg.tar.\(xz\|zst\)//g' | sed "s/$package-//g" | sort -Vr)
    if [ $? -ne 0 ]; then
      echo "Failed to fetch versions for $package from ALA."
      return
    fi
    version=$(echo "$versions" | dmenu -i -p "Select version to downgrade $package to: ")
    if [ -z "$version" ]; then
      echo "No version selected."
      return
    fi
    warning_message="WARNING: Downgrading a package can lead to system instability and could break dependencies with other packages. Proceed with caution!"
    download_file_xz="/var/cache/pacman/pkg/$package-$version.pkg.tar.xz"
    download_file_zst="/var/cache/pacman/pkg/$package-$version.pkg.tar.zst"
    original_owner=$(stat -c '%u:%g' /etc/pacman.conf)
    original_mode=$(stat -c '%a' /etc/pacman.conf)
    $terminal -e bash -c "unset WGETRC; \
      echo \$3; \
      if confirm_action \"Are you sure you want to continue with downgrading a package?\"; then
        if [ ! -f \"$download_file_xz\" ] && [ ! -f \"$download_file_zst\" ]; then \
          wget 'https://archive.archlinux.org/packages/${package:0:1}/$package/$package-$version.pkg.tar.xz' -P /var/cache/pacman/pkg/ || wget 'https://archive.archlinux.org/packages/${package:0:1}/$package/$package-$version.pkg.tar.zst' -P /var/cache/pacman/pkg/ || { echo 'Download failed'; exit 1; }; \
        fi; \
        if [ -f \"$download_file_xz\" ]; then \
          printf 'Installing the selected version...\n'; sudo pacman -U \"$download_file_xz\"; \
        elif [ -f \"$download_file_zst\" ]; then \
          printf 'Installing the selected version...\n'; sudo pacman -U \"$download_file_zst\"; \
        else \
          printf 'Download failed. Press ENTER to exit...\n'; \
        fi; \
        if confirm_action 'Would you like to ignore future updates to $package by adding it to pacman.conf ignore list?'; then \
          if grep -q \"^IgnorePkg.*$package\" /etc/pacman.conf; then \
            printf 'Package is already in the ignore list.\n'; \
          else \
            printf '***Added \"$package\" to /etc/pacman.conf IgnorePkg list*** \n'; \
            sudo awk -v pkg=$package '/^IgnorePkg/ {print \$0, pkg; next} {print}' /etc/pacman.conf > tmp && sudo mv tmp /etc/pacman.conf; \
          fi; \
        fi; \
        sudo chown \$1 /etc/pacman.conf; \
        sudo chmod \$2 /etc/pacman.conf; \
        printf 'Press ENTER to exit...'; read; \
      else
        echo \"Downgrade operation cancelled by the user.\"; \
        printf 'Press ENTER to exit...'; read; \
      fi" -- "$original_owner" "$original_mode" "$warning_message"
  elif auracle info $package >/dev/null 2>&1; then
    versions=$(find $AURACLE_CACHE_DIR/$package -type f -name "$package*.pkg.tar.zst" -printf '%f\n' | sed -n "s/^$package-\(.*\).pkg.tar.zst$/\1/p" | sort -Vr)
    version=$(echo "$versions" | dmenu -i -p "Select version to downgrade $package to: ")
    if [ -z "$version" ]; then
      echo "No version selected."
      return
    fi
    warning_message="WARNING: Downgrading a package can lead to system instability and could break dependencies with other packages. Proceed with caution!"
    pkg_file="$AURACLE_CACHE_DIR/$package/$package-$version.pkg.tar.zst"
    $terminal -e bash -c "
    echo \$1; \
    if confirm_action \"Are you sure you want to continue with downgrading a package?\"; then
      if [ -f \"$pkg_file\" ]; then \
        printf 'Installing the selected version...\n'; sudo pacman -U \"$pkg_file\"; \
      else \
        printf 'Installation failed. Press ENTER to exit...\n'; \
      fi; \
      printf 'Press ENTER to exit...'; read; \
      else
        echo \"Downgrade operation cancelled by the user.\"; \
        printf 'Press ENTER to exit...'; read; \
    fi" -- "$warning_message"
  else
    echo "Package $package not found."
  fi
}

# get the terminal to use
terminal=$(get_terminal)

# file to store the index
index_file="$INDEX_DIR/pkg_index.txt"

# update the index if it's more than a day old or if it doesn't exist
if [ ! -f "$index_file" ] || [ "$(( $(date +%s) - $(stat -c %Y "$index_file") ))" -gt 86400 ]; then
  pacman -Slq 2> /dev/null > "$index_file"
  list_aur_packages 2> /dev/null >> "$index_file"
fi

# get the action from the user
selected_action=$(echo -e "Install Package\nRemove Package\nUpdate Packages\nRemove Orphan Packages\nClear Package Cache\nDowngrade Package" | dmenu -i -p "Select action: ")

if [ "$selected_action" == "Install Package" ]; then
  install_package
elif [ "$selected_action" == "Remove Package" ]; then
  remove_package
elif [ "$selected_action" == "Update Packages" ]; then
  update_packages
elif [ "$selected_action" == "Remove Orphan Packages" ]; then
  remove_orphan_packages
elif [ "$selected_action" == "Clear Package Cache" ]; then
  clear_package_cache
elif [ "$selected_action" == "Downgrade Package" ]; then
  downgrade_package
fi

# Function to get user's selected action
get_selected_action() {
  echo -e "Install Package\nRemove Package\nUpdate Packages\nRemove Orphan Packages\nClear Package Cache\nDowngrade Package" | dmenu -i -p "Select action: "
}

# get the action from the user
selected_action=$(get_selected_action)

# Loop until user presses Escape or clicks outside of the dmenu
while [ -n "$selected_action" ]; do
  case "$selected_action" in
    "Install Package") install_package ;;
    "Remove Package") remove_package ;;
    "Update Packages") update_packages ;;
    "Remove Orphan Packages") remove_orphan_packages ;;
    "Clear Package Cache") clear_package_cache ;;
    "Downgrade Package") downgrade_package ;;
  esac

  # get the next action from the user
  selected_action=$(get_selected_action)
done
