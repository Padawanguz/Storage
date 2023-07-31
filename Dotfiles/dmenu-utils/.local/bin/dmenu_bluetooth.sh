#!/bin/bash

# This is a comprehensive bash script to manage your Bluetooth devices using the command line.
# It provides functionalities such as scanning for devices, pairing with devices, connecting to
# paired devices, removing devices, toggling Bluetooth power, and more.

# The script is interactive and uses dmenu for the user interface, which lets you select from
# various options.

# Dependencies:
# - dmenu: a generic menu for X, this is the interface of the script.
# - bluetoothctl: a command-line utility to control Bluetooth devices, it is part of the
#   bluez package in most Linux distributions.
# - systemctl: a utility for introspecting and controlling the state of the systemd system
#   and service manager, used to check the Bluetooth service status.
# - xdotool: a command-line X11 automation tool, it is used to simulate key press events.
# - A terminal emulator (e.g., xterm, Alacritty, etc.): The script will use the first
#   terminal it finds from a list of common terminals.

# The script first checks if a terminal emulator is installed. Then, it checks if the
# Bluetooth service and controller are active and powered on, respectively. If not, it
# offers to start and power them on. The script provides a menu of options to the user,
# including scanning for devices, showing paired devices, showing connected devices,
# removing a device, disconnecting all devices, and toggling various Bluetooth settings.

# The script uses several helper functions to perform its tasks. Each function is designed
# to do one specific task, making the script modular and easy to maintain.

# To use the script, make it executable and run it. You will be presented with a menu of
# options. Select an option to perform that action.

# Note: Some actions require root permissions. The script will ask for your password as
# needed.

# Find the terminal emulator
get_terminal() {
  terminal=$(command -v st kitty rxvt sakura lilyterm roxterm termite Alacritty xterm 2>/dev/null | head -n 1)
  if [ -z "$terminal" ]; then
    echo "No terminal emulator found. This script requires a terminal emulator to be installed."
    exit 1
  fi
  echo "$terminal"
}

# Check if required commands are available
for cmd in bluetoothctl dmenu xdotool; do
  if ! command -v $cmd &> /dev/null; then
    echo "error: $cmd could not be found. Please install $cmd."
    exit 1
  fi
done

# Function to show processing status in dmenu
show_processing_status() {
    (echo "            Scanning for 10 Seconds...         " | dmenu -p "Status") &
    dmenu_pid=$!

    # Use xdotool to simulate a key press to close dmenu after 1 second
    sleep 10 && xdotool key Escape

    # Wait for dmenu to close
    wait $dmenu_pid
}

# Function to get MAC address
get_mac_address() {
    echo "$1" | awk '{print $1}'
}

# Function to check if a device is connected and ask to disconnect
check_and_disconnect() {
    local mac_address=$(get_mac_address "$1")
    if (echo "info $mac_address"; sleep 0.5; echo "quit") | bluetoothctl | grep -q "Connected: yes"; then
        echo "The device is already connected"
        st -e bash -c "\
        read -p 'Do you want to disconnect? (y/n) ' disconnect;\
        if [[ \$disconnect =~ ^[Yy]$ ]]; then
            echo -e \"disconnect $mac_address\\nquit\" | bluetoothctl
        fi"
    fi
}

# Function to toggle Bluetooth
toggle_bluetooth() {
    BLUETOOTH_STATUS=$(bluetoothctl show | grep 'Powered:' | awk '{print $2}')
    if [ "$BLUETOOTH_STATUS" = "yes" ]; then
        (echo "power off"; sleep 0.25; echo "exit") | bluetoothctl && echo 'Bluetooth turned off.'
    else
        (echo "power on"; sleep 0.25; echo "exit") | bluetoothctl && echo 'Bluetooth turned on.'
    fi
}

# Function to check if the Bluetooth service is active and offer to start it
check_bluetooth_service() {
  terminal=$(get_terminal)
    if ! systemctl is-active --quiet bluetooth; then
        $terminal -e bash -c "\
        echo 'The Bluetooth service is not currently active.';\
        read -p 'Do you want to start it? (y/n) ' start;\
        if [[ \$start =~ ^[Yy]$ ]]; then
            show_processing_status &
            sudo systemctl start bluetooth
            wait
        else
            echo 'Exiting as the Bluetooth service is not active.';
            exit 1;
        fi"
    fi
}

# Function to check if the Bluetooth controller is powered on and offer to power it on
check_bluetooth_controller() {
  terminal=$(get_terminal)
    if ! (echo "show") | bluetoothctl | grep -q "Powered: yes"; then
        $terminal -e bash -c "\
        echo 'The Bluetooth controller is not currently powered on.';\
        read -p 'Do you want to power it on? (y/n) ' poweron;\
        if [[ \$poweron =~ ^[Yy]$ ]]; then
            show_processing_status &
            echo -e \"power on\\nquit\" | bluetoothctl
            wait
        else
            echo 'Exiting as the Bluetooth controller is not powered on.';
            exit 1;
        fi"
    fi
}

# Function to list all connected devices and disconnect
connected_devices() {
    # Check if the Bluetooth service is active, if not, offer to start it
    check_bluetooth_service

    # Check if the Bluetooth controller is powered on, if not, offer to power it on
    check_bluetooth_controller

    known_devices=$(echo -e "devices" | bluetoothctl | awk '/Device/ {print $2 " " substr($0, index($0,$4))}')
    connected_devices=""
    for device in $known_devices; do
        device_mac_address=$(get_mac_address "$device")
        if (echo "info $device_mac_address"; echo "quit") | bluetoothctl | grep -q "Connected: yes"; then
            device_name=$(echo -e "info $device_mac_address" | bluetoothctl | awk '/Name/ {print substr($0, index($0,$2))}')
            connected_devices+="$device_mac_address $device_name\n"
        fi
    done
    if [ -z "$connected_devices" ]; then
        echo "No connected devices. Returning to main menu."
        main_menu
        return
    fi
    device=$(echo -e "$connected_devices" | dmenu -i -p "Select a device:")
    if [ -z "$device" ]; then
        echo "No device selected. Returning to main menu."
        main_menu
        return
    fi
    device_mac_address=$(echo $device | cut -d ' ' -f1)
    check_and_disconnect "$device_mac_address"
}

# Function to list paired devices and connect
paired_devices() {
    # Use the list_paired_devices function to get the list of paired devices
    device=$(list_paired_devices)

    # Check if a device was selected
    if [ -z "$device" ]; then
        echo "No device selected. Returning to main menu."
        main_menu
        return
    fi

    check_and_disconnect "$device"
    (echo -e "connect $(get_mac_address "$device")\nquit") | bluetoothctl > /dev/null 2>&1

# Return to main menu after operation is completed
    main_menu
}

# Function to list paired devices and return the selected one
list_paired_devices() {
    # Check if the Bluetooth service is active, if not, offer to start it
    check_bluetooth_service

    # Check if the Bluetooth controller is powered on, if not, offer to power it on
    check_bluetooth_controller

    paired_devices=$(echo "devices" | bluetoothctl | awk '/Device/ {print $2 " " substr($0, index($0,$4))}')
    if [ -z "$paired_devices" ]; then
        echo "No paired devices. Returning to main menu."
        main_menu
        return
    fi
    device=$(echo -e "$paired_devices" | dmenu -i -p "Select a device:")
    if [ -z "$device" ]; then
        echo "No device selected. Returning to main menu."
        main_menu
        return
    fi
    echo "$device"
}

# Function to remove a paired device
remove_device() {
    # Use the list_paired_devices function to get the list of paired devices
    device=$(list_paired_devices)

    # Check if a device was selected
    if [ -z "$device" ]; then
        echo "No device selected."
        return 1
    fi

    # Get terminal emulator
    terminal=$(get_terminal)

    # Get MAC address directly from $device
    mac_address=$(echo "$device" | awk '{print $1}')

    # Check if the device is paired before attempting to remove
    if ! (echo "info $mac_address"; sleep 0.5; echo "quit") | bluetoothctl | grep -q "Paired: yes"; then
        echo "The device is not paired. Nothing to remove."
        return 1
    fi

    # Ask for confirmation before removing the device
    $terminal -e bash -c "\
    echo 'You have selected the following device for removal:';\
    echo \$0;\
    read -p 'Do you want to remove this device? (y/n) ' remove;\
    if [[ \$remove =~ ^[Yy]$ ]]; then
        echo -e \"remove \$1\\nquit\" | bluetoothctl > /dev/null 2>&1
    fi" "$device" "$mac_address" # Passing $device and $mac_address as arguments to the bash command
}

# Function to disconnect from all devices
disconnect() {
    connected_devices=$(echo "devices" | bluetoothctl | awk '/Device/ {print $2}')
    for mac_address in $connected_devices; do
        if (echo "info $mac_address"; sleep 0.5; echo "quit") | bluetoothctl | grep -q "Connected: yes"; then
            echo -e "disconnect $mac_address\\nquit" | bluetoothctl > /dev/null 2>&1
        fi
    done
}

# Function to toggle Discoverable
toggle_discoverable() {
    DISCOVERABLE_STATUS=$(echo "show" | bluetoothctl | grep 'Discoverable:' | awk '{print $2}')
    if [ "$DISCOVERABLE_STATUS" = "yes" ]; then
        bluetoothctl discoverable off && bluetoothctl exit && echo 'Discoverable turned off.'
    else
        bluetoothctl discoverable on && bluetoothctl exit && echo 'Discoverable turned on.'
    fi
    sleep 0.25
    options_menu
    return
}

# Function to toggle Pairable
toggle_pairable() {
    PAIRABLE_STATUS=$(echo "show" | bluetoothctl | grep 'Pairable:' | awk '{print $2}')
    if [ "$PAIRABLE_STATUS" = "yes" ]; then
        bluetoothctl pairable off && bluetoothctl exit && echo 'Pairable turned off.'
    else
        bluetoothctl pairable on && bluetoothctl exit && echo 'Pairable turned on.'
    fi
    sleep 0.25
    options_menu
    return
}

# Function to check Bluetooth power status
check_power_status() {
    echo "show" | bluetoothctl | grep 'Powered:' | awk '{print $2}'
}

# Function to check Bluetooth scan status
check_scan_status() {
    echo "show" | bluetoothctl | grep 'Discovering:' | awk '{print $2}'
}

# Function to check Bluetooth pairable status
check_pairable_status() {
    echo "show" | bluetoothctl | grep 'Pairable:' | awk '{print $2}'
}

# Function to check Bluetooth discoverable status
check_discoverable_status() {
    echo "show" | bluetoothctl | grep 'Discoverable:' | awk '{print $2}'
}

# Function to handle Options
options_menu() {
    # Get current statuses
    local power_status=$(check_power_status)
    local pairable_status=$(check_pairable_status)
    local discoverable_status=$(check_discoverable_status)

# Map power_status "yes" to "ON" and "no" to "OFF"
    if [ "$power_status" = "yes" ]; then
        power_status="ON"
    elif [ "$power_status" = "no" ]; then
        power_status="OFF"
    fi

    # Present dmenu options to the user
    options="Power [$power_status]\nPairable [$pairable_status]\nDiscoverable [$discoverable_status]"
    selected_option=$(echo -e $options | dmenu -i -p "Select an option:")

 # If Esc was pressed, selected_option will be empty. Return to main menu.
    if [ -z "$selected_option" ]; then
        main_menu
        return
    fi

    # Perform the selected action
    selected_option_stripped=${selected_option%% [*}
    case "$selected_option_stripped" in
        "Power")
            toggle_bluetooth
            ;;
        "Pairable")
            toggle_pairable
            ;;
        "Discoverable")
            toggle_discoverable
            ;;
        *)
            echo "Invalid option. Exiting."
            exit 1
            ;;
    esac

    # Return to options menu after operation is completed
    options_menu
}

scan_for_devices() {
  # Create a temporary file to hold the devices
  tmpfile=$(mktemp)

  # Check if the Bluetooth service is active, if not, offer to start it
  check_bluetooth_service

  # Check if the Bluetooth controller is powered on, if not, offer to power it on
  check_bluetooth_controller

  # Scan for devices
  while true; do
      show_processing_status &
      (echo "scan on"; sleep 10; echo "scan off"; echo "quit") | bluetoothctl | awk '/Device/ {print $2 " " substr($0, index($0,$4))}' | sort -u > $tmpfile
      wait

      # Check if any devices were found
      if [ $(wc -l < $tmpfile) -eq 0 ]; then
          # Add option to rescan
          options="No devices found\nRescan"
      else
          # Show list of found devices
          options=$(cat $tmpfile)
      fi

      # Present dmenu options to the user
      selected_option=$(echo -e $options | dmenu -i -p "Select a device")

      # Check if user wants to rescan
      if [ "$selected_option" = "Rescan" ]; then
          continue
      else
          main_menu
      fi
  done

  # Remove duplicate devices from the list
  deduped_tmpfile=$(mktemp)
  sort $tmpfile | uniq > $deduped_tmpfile

  # Select a device using dmenu
  device=$(awk '{$1=""; print $0}' $deduped_tmpfile | dmenu -i -p "Select a device:")

  # If no device was selected, exit
  if [ -z "$device" ]; then
      echo "No device selected. Exiting."
      exit 1
  fi

  # Retrieve the MAC address corresponding to the selected device
  mac_address=$(grep "$device" $tmpfile | awk '{print $2}')

  # Trim leading whitespace
  device=$(echo $device | sed -e 's/^[[:space:]]*//')

  # Check if the selected device is already paired
  if (echo "info $mac_address"; sleep 0.5; echo "quit") | bluetoothctl | grep -q "Paired: yes"; then
      # If it is, connect to that device
      if (echo "info $mac_address"; sleep 0.5; echo "quit") | bluetoothctl | grep -q "Connected: yes"; then
          echo "The device is already connected"
          st -e bash -c "\
          read -p 'Do you want to disconnect? (y/n) ' disconnect;\
          if [[ \$disconnect =~ ^[Yy]$ ]]; then
              echo -e \"disconnect $mac_address\\nquit\" | bluetoothctl > /dev/null 2>&1
          fi"
      else
          (echo "connect $mac_address"; sleep 5; "quit") | bluetoothctl > /dev/null 2>&1
      fi
  else
      # If it's not, pair and connect to that device
      # Attempt to pair with the device
      (echo "pair $mac_address"; sleep 5; echo "quit") | bluetoothctl > /dev/null 2>&1

      # Check if pairing was successful
      if ! (echo "info $mac_address"; sleep 0.5; echo "quit") | bluetoothctl | grep -q "Paired: yes"; then
          # If not, ask for a PIN and try to pair again
          $terminal -e bash -c "\
          echo 'Failed to pair with the device. It might require a PIN.';\
          read -p 'Enter the PIN: ' pin;\
          # show_processing_status &
          echo -e \"pair $mac_address\\n$pin\\nquit\" | bluetoothctl > /dev/null 2>&1"
      fi

      (echo "connect $mac_address"; sleep 5; echo "quit") | bluetoothctl > /dev/null 2>&1
  fi

  # Delete the temporary files
  rm $tmpfile
  rm $deduped_tmpfile
}

# Function for the main menu
main_menu() {
    local power_status=$(check_power_status)

# Map power_status "yes" to "ON" and "no" to "OFF"
    if [ "$power_status" = "yes" ]; then
        power_status="ON"
    elif [ "$power_status" = "no" ]; then
        power_status="OFF"
    fi

    # Present dmenu options to the user
    options="Scan for Devices\nPaired Devices\nConnected Devices\nRemove Device\nDisconnect All\nOptions"
    selected_option=$(echo -e $options | dmenu -i -p "Bluetooth Device is $power_status")

    # Perform the selected action
    case "$selected_option" in
        "Paired Devices")
            paired_devices
            ;;
        "Disconnect All")
            disconnect
            ;;
        "Connected Devices")
            connected_devices
            ;;
        "Remove Device")
            remove_device
            ;;
        "Options")
            options_menu
            ;;
        "Scan for Devices")
          scan_for_devices
            ;;
        *)
            echo "Invalid option. Exiting."
            exit 1
            ;;
    esac
}

# Start with the main menu
main_menu
