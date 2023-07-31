#!/bin/bash

# This script is a versatile tool for managing removable devices from the command line.
# It offers a wide range of capabilities, including mounting and unmounting devices,
# showing disk usage, checking disk health, backing up disks, checking and repairing filesystems,
# flashing OS images, formatting disks, wiping disks, and handling LUKS-encrypted devices.
# The script relies on several command-line tools and expects them to be installed and available
# in the system's PATH.

# Dependencies:
# - dmenu: a generic menu for X, used for presenting interactive options to the user
# - cryptsetup: a utility for setting up disk encryption based on the DMCrypt kernel module
# - dmsetup: a low-level logical volume management (LVM) utility
# - udisksctl: a command-line program used to interact with the udisks daemon process
# - mountpoint: a command that checks if a directory or file is a mountpoint
# - awk, grep, sed, and other standard Unix command-line utilities
# - A terminal emulator (the script checks for several options and uses the first one it finds)

# Please make sure all dependencies are installed before running this script.
# The script also requires root privileges for several operations, especially those involving
# disk formatting, encryption, and certain types of mounting and unmounting.


# Find the terminal emulator
get_terminal() {
  terminal=$(command -v st kitty rxvt sakura lilyterm roxterm termite Alacritty xterm 2>/dev/null | head -n 1)
  if [ -z "$terminal" ]; then
    echo "No terminal emulator found. This script requires a terminal emulator to be installed."
    exit 1
  fi
  echo "$terminal"
}

# Function to get list of mounted devices
get_mounted() {
  mounted_devices=$(lsblk -r -p -o name,rm,mountpoint | grep -v '^/dev/sr' | awk '$3!="" && $2=="1" && $1~/[0-9]$/ {print $1}' | sed 's_/dev/__')
  [ -n "$mounted_devices" ] && echo "$mounted_devices"
}

# Function to get list of unmounted devices
get_unmounted() {
  unmounted_devices=$(lsblk -r -p -o name,rm,mountpoint | grep -v '^/dev/sr' | awk '$3=="" && $2=="1" && $1~/[0-9]$/ {print $1}' | sed 's_/dev/__')
  [ -n "$unmounted_devices" ] && echo "$unmounted_devices"
}

# Function to remove /dev/ prefix from device names
remove_dev_prefix() {
  sed 's_/dev/__'
}

# Function to handle a device
handle_device() {
  local terminal=$(get_terminal)
  local device=$1
  local action=$2
  local result

  if [[ $action == "mount" ]]; then
    result=$(udisksctl mount -b /dev/$device 2>&1)
    if [ $? -eq 0 ]; then
      $terminal -e bash -c "echo 'Successfully mounted $device to $(echo $result | awk '{print $4}')'; echo 'Press Enter to continue...'; read line"
    else
      $terminal -e bash -c "echo 'Unable to mount $device. Error: $result'; echo 'Press Enter to continue...'; read line"
    fi
  elif [[ $action == "unmount" ]]; then
    result=$(udisksctl unmount -b /dev/$device 2>&1)
    if [ $? -eq 0 ]; then
      $terminal -e bash -c "echo 'Successfully unmounted $device.'; echo 'Press Enter to continue...'; read line"
    else
      $terminal -e bash -c "echo 'Unable to unmount $device. Error: $result'; echo 'Press Enter to continue...'; read line"
    fi
  fi
}

# Function to get a device mount point
get_mount_point() {
  local device=$1
  lsblk /dev/$device -o MOUNTPOINT -nl
}

# Function to show disk usage statistics
show_disk_usage() {
  local terminal=$(get_terminal)
  local device=$(lsblk -r -p -o name,rm,mountpoint | grep -v '^/dev/sr' | awk '$2=="1" && $1~/[0-9]$/ {print $1}' | remove_dev_prefix | dmenu -i -p "Select a device to show disk usage: ")

  # If no device is selected, return to the submenu
  if [ -z "$device" ]; then
    return
  fi

  $terminal -e bash -c "df -h /dev/$device; echo 'Press Enter to close this window...'; read line"
}

# Function to open a device in terminal or GUI
open_device() {
  local terminal=$(get_terminal)
  local device=$1
  local mount_point=$(get_mount_point $device)

  local option=$(echo -e "Terminal\nGUI" | dmenu -i -p "Open $device in: ")

  if [[ $option == "Terminal" ]]; then
    $terminal -e bash -c "cd $mount_point; exec $SHELL"
  elif [[ $option == "GUI" ]]; then
    xdg-open $mount_point
  fi
}

# Function to check disk health
check_disk_health() {
  local terminal=$(get_terminal)
  local device=$(lsblk -r -p -o name,rm,mountpoint | grep -v '^/dev/sr' | awk '$2=="1" && $1~/[0-9]$/ {print $1}' | remove_dev_prefix | dmenu -i -p "Select a device to check health: ")

  # If no device is selected, return to the submenu
  if [ -z "$device" ]; then
    return
  fi

  $terminal -e bash -c "echo 'About to check health of $device. This operation may require root permissions.'; echo 'Press Enter to continue...'; read line; sudo smartctl -H /dev/$device; echo 'Press Enter to close this window...'; read line"
}

# Function to backup disk
backup_disk() {
  local terminal=$(get_terminal)
  local device=$(lsblk -r -p -o name,rm,mountpoint | grep -v '^/dev/sr' | awk '$2=="1" && $1~/[0-9]$/ {print $1}' | remove_dev_prefix | dmenu -i -p "Select a device to backup: ")

  # If no device is selected, return to the submenu
  if [ -z "$device" ]; then
    return
  fi

  $terminal -e bash -c "echo 'Enter the full path of the directory where you want to save the backup:'; read location; if [ ! -d \$location ]; then echo 'Invalid backup location entered. Exiting...'; exit 1; fi; if [ ! -w \$location ]; then echo 'No write permissions to backup location. Exiting...'; exit 1; fi; device_size=\$(lsblk -b -dn -o SIZE /dev/$device); available_space=\$(df --output=avail -B1 \"\$location\" | tail -n1); if (( device_size > available_space )); then echo 'Not enough free space at backup location. Exiting...'; exit 1; fi; backup_file=\"\$location/$(basename $device)_backup.img\"; echo 'About to backup $device to '\$backup_file'. This operation may require root permissions.'; echo 'Press Enter to continue...'; read line; sudo dd if=/dev/$device of=\$backup_file bs=64K conv=noerror,sync status=progress; echo 'Backup completed. Press Enter to close this window...'; read line"
}

# Function to check and repair filesystem
check_and_repair_filesystem() {
  local terminal=$(get_terminal)
  local device=$(lsblk -r -p -o name,rm,mountpoint | grep -v '^/dev/sr' | awk '$2=="1" && $1~/[0-9]$/ {print $1}' | remove_dev_prefix | dmenu -i -p "Select a device to check and repair: ")

  # If no device is selected, return to the submenu
  if [ -z "$device" ]; then
    return
  fi

  # Check if the device is mounted
  local mount_point=$(get_mount_point $device)

  if [ -n "$mount_point" ]; then
    # If the device is mounted, inform the user and ask for permission to unmount
    $terminal -e bash -c "echo 'The selected device $device is currently mounted at $mount_point. It needs to be unmounted before filesystem check and repair. If you have any open files or unsaved changes on this device, you should save your changes and close any open files now. If you continue, all data on the device may be lost. Press Enter to unmount the device and continue...'; read line; sudo udisksctl unmount -b /dev/$device; echo 'Device unmounted. Press Enter to continue...'; read line; echo 'About to check and repair filesystem on $device. This operation may require root permissions.'; echo 'Press Enter to continue...'; read line; sudo fsck /dev/$device; echo 'Filesystem check and repair completed. Press Enter to close this window...'; read line"
  else
    $terminal -e bash -c "echo 'About to check and repair filesystem on $device. This operation may require root permissions.'; echo 'Press Enter to continue...'; read line; sudo fsck /dev/$device; echo 'Filesystem check and repair completed. Press Enter to close this window...'; read line"
  fi
}

# Function to securely wipe a disk
wipe_disk() {
  local terminal=$(get_terminal)
  local device=$(lsblk -r -p -o name,rm,mountpoint | grep -v '^/dev/sr' | awk '$2=="1" && $1~/[0-9]$/ {print $1}' | remove_dev_prefix | dmenu -i -p "Select a device to wipe: ")

  # If no device is selected, return to the submenu
  if [ -z "$device" ]; then
    return
  fi

  # Warn the user that all data on the device will be erased and wipe the disk upon user's confirmation
  $terminal -e bash -c "echo 'WARNING: All data on the target device $device will be permanently erased! Please make sure you have selected the correct target device. Press Enter to continue...'; read line; echo 'Wiping $device. This operation may require root permissions and can take some time, depending on the size of the device.'; echo 'Press Enter to continue...'; read line; sudo dd if=/dev/zero of=/dev/$device bs=4M status=progress; echo 'Disk wiping completed. Press Enter to close this window...'; read line"
}

# Function to browse directories using dmenu, ignoring hidden files/directories
# and only allowing selection of valid image file types
browse_directory() {
    local start_dir="${1:-$HOME}"
    local current_dir="$start_dir"
    local dir_stack=("$start_dir")

    while true; do
        local file
        file=$(printf "%s\n" ".." $(find "$current_dir" -mindepth 1 -maxdepth 1 -not -name '.*' \( -type d -o -type f \( -name '*.img' -o -name '*.iso' -o -name '*.bin' -o -name '*.dsk' \) \)) | dmenu -i -p "Select a file or directory: ")

        # If no file or directory is selected (Esc was pressed), exit the function
        if [ -z "$file" ]; then
            return
        fi

        # If ".." was selected, go back to the previous directory
        if [ "$file" = ".." ]; then
            unset dir_stack[-1]  # Remove the top directory from the stack
            current_dir="${dir_stack[-1]}"  # Set the current directory to the new top directory
            continue
        fi

        # If the directory exists, set it as the current directory
        if [ -d "$file" ]; then
            dir_stack+=("$file")  # Push the directory onto the stack
            current_dir="$file"
        else
            echo "$file"
            return
        fi
    done
}

# Function to flash images onto SD cards and USB drives
flash_image() {
    local terminal=$(get_terminal)
    local device=$(lsblk -r -p -o name,rm,mountpoint | grep -v '^/dev/sr' | awk '$2=="1" && $1~/[0-9]$/ {print $1}' | remove_dev_prefix | dmenu -i -p "Select a target device (SD card or USB drive) to flash the image onto: ")

    # If no device is selected, return to the submenu
    if [ -z "$device" ]; then
        return
    fi

    # Check if the device is mounted
    local mount_point=$(get_mount_point $device)

    if [ -z "$mount_point" ]; then
        # If the device is not mounted, mount it
        handle_device $device "mount"
    fi

    # Ask the user for the image file location in the terminal
    local image_file=$(browse_directory)
    if [ ! -f "$image_file" ]; then
        echo 'Invalid file path entered. Exiting...'
        exit 1
    fi
    local image_size=$(du -b "$image_file" | cut -f1)
    local device_size=$(lsblk -b -dn -o SIZE "/dev/$device")
    if (( image_size > device_size )); then
        echo 'Not enough free space on the target device. Exiting...'
        exit 1
    fi

    # Use the terminal to display warnings and progress
    $terminal -e bash -c "echo 'WARNING: All data on the target device /dev/$device will be erased! Please make sure you have selected the correct target device. Press Enter to continue...'; read line; echo 'Flashing image $image_file onto /dev/$device. This operation may require root permissions and can take some time, depending on the size of the image file.'; echo 'Press Enter to continue...'; read line; sudo dd if=\"$image_file\" of=\"/dev/$device\" bs=4M status=progress; echo 'Image flashing completed. Press Enter to close this window...'; read line"
}

# Function to unlock an encrypted device
unlock_device() {
  local terminal=$(get_terminal)
  local device=$(lsblk -r -p -o name,rm,mountpoint | grep -v '^/dev/sr' | awk '$2=="1" && $1~/[0-9]$/ {print $1}' | remove_dev_prefix | dmenu -i -p "Select an encrypted device to unlock: ")

  # If no device is selected, return to the submenu
  if [ -z "$device" ]; then
    return
  fi

  # Generate a random mapper name
  local mapper_name=$(uuidgen)

  $terminal -e bash -c "echo 'About to unlock $device. This operation requires root permissions.'; sudo cryptsetup luksOpen /dev/$device $mapper_name && echo 'Device unlocked.' && echo 'Mounting the device...' && udisksctl mount -b /dev/mapper/$mapper_name && echo 'Device mounted. Press Enter to close this window...'; read line"
}

# Function to lock an encrypted device
lock_device() {
  local terminal=$(get_terminal)

  $terminal -e bash -c "echo 'About to lock a decrypted device. This operation requires root permissions.'; echo 'Press Enter to continue...'; read line; map_dev=\$(sudo dmsetup ls --target crypt | awk '{print \$1}' | xargs -I {} sh -c 'echo {} \$(readlink -f /dev/mapper/{})' | dmenu -i -p 'Select a decrypted device to lock: '); mapper_name=\$(echo \$map_dev | awk '{print \$1}'); device_path=\$(echo \$map_dev | awk '{print \$2}'); if [ -z \"\$mapper_name\" ]; then echo 'No device selected. Exiting...'; exit 1; fi; echo 'Unmounting the device...'; sudo umount \$device_path; echo 'Locking the device...'; sudo cryptsetup luksClose \$mapper_name; echo 'Device locked. Press Enter to close this window...'; read line"
}

# Function to encrypt a device
encrypt_device() {
  local terminal=$(get_terminal)
  local device=$(lsblk -r -p -o name,rm,mountpoint | grep -v '^/dev/sr' | awk '$2=="1" && $1~/[0-9]$/ {print $1}' | remove_dev_prefix | dmenu -i -p "Select a device to encrypt: ")

  # If no device is selected, return to the submenu
  if [ -z "$device" ]; then
    echo 'No device selected. Returning to the submenu.'
    return
  fi

  # Ask the user for the filesystem they want to format the device in
  local filesystem=$(echo -e "ext2\next3\next4\nntfs\nfat32\nexfat\nbtrfs\nxfs\njfs\nreiserfs" | dmenu -i -p "Select a filesystem to format $device in: ")

  # If no filesystem is selected, return to the submenu
  if [ -z "$filesystem" ]; then
    echo 'No filesystem selected. Returning to the submenu.'
    return
  fi

  # Map user-friendly filesystem names to the correct mkfs command
  case $filesystem in
    "fat32")
      filesystem="vfat"
      ;;
  esac

  $terminal -e bash -c "echo 'About to encrypt $device. This operation requires root permissions and will erase all data on the device. Please ensure you have backed up any important data.'; sleep 3; echo 'Enter a passphrase for $device:'; read -s passphrase; echo 'Confirm the passphrase:'; read -s passphrase_confirmation; if [ \"\$passphrase\" != \"\$passphrase_confirmation\" ]; then echo 'Passphrases do not match. Exiting...'; exit 1; fi; echo 'Encrypting $device...'; echo -n \$passphrase | sudo cryptsetup -q luksFormat /dev/$device -; echo 'Device encrypted.'; sleep 2; echo 'Creating filesystem...'; sudo cryptsetup open /dev/$device temp_crypt; echo 'Opened the device.'; sleep 2; sudo mkfs.\$0 /dev/mapper/temp_crypt; echo 'Filesystem created.'; sleep 2; echo 'Syncing the filesystem...'; sync; echo 'Syncing done.'; sleep 2; echo 'Closing the device...'; sudo cryptsetup close temp_crypt; echo 'Device closed and encryption completed. Press Enter to close this window...'; read line" $filesystem
}

# Function to format a device
format_device() {
  local terminal=$(get_terminal)
  local device=$(lsblk -r -p -o name,rm,mountpoint | grep -v '^/dev/sr' | awk '$2=="1" && $1~/[0-9]$/ {print $1}' | remove_dev_prefix | dmenu -i -p "Select a device to format: ")

  # If no device is selected, return to the submenu
  if [ -z "$device" ]; then
    return
  fi

  local mount_point=$(get_mount_point $device)

  # If the device is mounted, ask the user for permission to unmount it
  if [ -n "$mount_point" ]; then
    $terminal -e bash -c "echo 'The device $device is currently mounted. It needs to be unmounted in order to proceed with formatting. Press Enter to continue...'; read line"
    handle_device $device "unmount"
  fi

  # Ask the user for the filesystem they want to format the device in
  local filesystem=$(echo -e "ext2\next3\next4\nntfs\nfat32\nexfat\nbtrfs\nxfs\njfs\nreiserfs" | dmenu -i -p "Select a filesystem to format $device in: ")

  # If no filesystem is selected, return to the submenu
  if [ -z "$filesystem" ]; then
    return
  fi

  # Map user-friendly filesystem names to the correct mkfs command
  case $filesystem in
    "fat32")
      filesystem="vfat"
      ;;
  esac

  # Execute the format command, and inform the user about it
  $terminal -e bash -c "echo 'The following command will be executed: sudo mkfs.$filesystem /dev/$device. This will erase all data on the device. Press Enter to continue...'; read line; sudo -v; sudo mkfs.$filesystem /dev/$device; echo 'Press Enter to close this window...'; read line"
}

# Main function
main() {
  while true; do
    local mounted_count=$(get_mounted | wc -l)
    local unmounted_count=$(get_unmounted | wc -l)

    local choice=$(echo -e "$unmounted_count Unmounted\n$mounted_count Mounted\nOpen Disks\nUtilities\nEncryption" | dmenu -i -p "Select an option: ")

    case $choice in
      "$unmounted_count Unmounted")
        local device=$(get_unmounted | dmenu -i -p "Select a device to mount: ")
        if [ -z "$device" ]; then
          continue
        fi
        handle_device $device "mount"
        ;;
      "$mounted_count Mounted")
        local device=$(get_mounted | dmenu -i -p "Select a device to unmount: ")
        if [ -z "$device" ]; then
          continue
        fi
        handle_device $device "unmount"
        ;;
      "Open Disks")
        local device=$(get_mounted | dmenu -i -p "Select a device to open: ")
        if [ -z "$device" ]; then
          continue
        fi
        open_device $device
        ;;
      "Utilities")
        utilities_submenu
        ;;
      "Encryption")
        encryption_submenu
        ;;
      *)
        break
        ;;
    esac
  done
}

# Utilities Submenu function
utilities_submenu() {
  while true; do
    local option=$(echo -e "Show Disk Usage\nCheck Disk Health\nBackup Disk\nCheck and Repair Filesystem\nFlash OS Image\nFormat Disk\nWipe Disk" | dmenu -i -p "Select a utility: ")

    case $option in
      "Show Disk Usage")
        show_disk_usage
        ;;
      "Check Disk Health")
        check_disk_health
        ;;
      "Backup Disk")
        backup_disk
        ;;
      "Check and Repair Filesystem")
        check_and_repair_filesystem
        ;;
      "Flash OS Image")
        flash_image
        ;;
      "Format Disk")
        format_device
        ;;
      "Wipe Disk")
        wipe_disk
        ;;
      *)
        # Return to the main menu if anything other than the specified options is selected
        break
        ;;
    esac
  done
}

# Encryption Submenu function
encryption_submenu() {
  while true; do
    local option=$(echo -e "Unlock Encrypted Disk\nLock Encrypted Disk\nEncrypt Disk" | dmenu -i -p "Select an encryption option: ")

    case $option in
      "Unlock Encrypted Disk")
        unlock_device
        ;;
      "Lock Encrypted Disk")
        lock_device
        ;;
      "Encrypt Disk")
        encrypt_device
        ;;
      *)
        # Return to the previous menu if anything other than the specified options is selected
        break
        ;;
    esac
  done
}

# Check if dmenu is installed
if ! command -v dmenu &> /dev/null
then
    echo "dmenu could not be found. Please install it and run this script again."
    exit 1
fi

main
