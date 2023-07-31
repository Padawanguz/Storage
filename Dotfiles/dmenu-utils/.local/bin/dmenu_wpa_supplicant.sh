#!/bin/bash

# Function to get the wireless interface
get_wireless_interface() {
  interfaces=$(ls /sys/class/net)
  for interface in $interfaces; do
    if [[ $(cat /sys/class/net/$interface/type) -eq 1 ]]; then
      echo "$interface"
      return
    fi
  done
  echo "No wireless interface found. Exiting."
  exit 1
}

# Find the terminal emulator
get_terminal() {
  terminal=$(command -v st kitty xterm rxvt sakura lilyterm roxterm termite Alacritty 2>/dev/null | head -n 1)
  if [ -z "$terminal" ]; then
    echo "No terminal emulator found. This script requires a terminal emulator to be installed."
    exit 1
  fi
  echo "$terminal"
}

# Function to toggle wifi on and off
toggle_wifi() {
  interface=$1
  terminal=$(get_terminal)
  wifi_state=$(ip link show $interface | grep -q 'UP' && echo 'ON' || echo 'OFF')
  $terminal -e bash -c "\
  echo 'Requesting root password to continue...';
  if ip link show \$0 | grep -q 'UP'; then
    sudo ip link set \$0 down && echo 'Wifi turned off.';
  else
    sudo ip link set \$0 up && echo 'Wifi turned on.';
  fi" "$interface"
  wifi_state=$(ip link show $interface | grep -q 'UP' && echo 'ON' || echo 'OFF')
  echo $wifi_state
}

# Function to wait for connection to complete
wait_for_connection() {
  local interface=$1
  local selected_ssid=$2
  count=0
  while true; do
    current_ssid=$(wpa_cli -i $interface status | awk -F= '$1=="ssid" {print $2}')
    wpa_state=$(wpa_cli -i $interface status | awk -F= '$1=="wpa_state" {print $2}')
    if [ "$wpa_state" = "COMPLETED" ] && [ "$current_ssid" = "$selected_ssid" ]; then
      break
    fi
    sleep 1
    count=$((count + 1))
    if [ $count -ge 10 ]; then
      echo "Failed to connect to $selected_ssid within 10 seconds."
      restore_wpa_supplicant_conf
      break
    fi
  done
}

# Function to check if the selected ssid is already in wpa_supplicant.conf
is_ssid_in_wpa_supplicant() {
  local selected_ssid=$1
  if grep -q "$selected_ssid" /etc/wpa_supplicant/wpa_supplicant.conf; then
    return 0
  else
    return 1
  fi
}

# Function to check if the selected ssid is already in wpa_supplicant.conf
backup_wpa_config() {
  echo 'Requesting root password to proceed...'
  sudo cp /etc/wpa_supplicant/wpa_supplicant.conf /etc/wpa_supplicant/wpa_supplicant.conf.bak
  if [ $? -ne 0 ]; then
    echo 'Failed to backup wpa_supplicant.conf'
    exit 1
  fi
  echo 'Successfully backed up wpa_supplicant.conf'
}

# Function to restore wpa_supplicant.conf if connection fails
restore_wpa_supplicant_conf() {
  sudo mv /etc/wpa_supplicant/wpa_supplicant.conf.bak /etc/wpa_supplicant/wpa_supplicant.conf
  if [ $? -ne 0 ]; then
    echo 'Failed to restore wpa_supplicant.conf'
    exit 1
  else
    echo 'Successfully restored wpa_supplicant.conf'
  fi
}

# Function to display saved networks
display_saved_networks() {
  networks=$(grep 'ssid="' /etc/wpa_supplicant/wpa_supplicant.conf | cut -d'"' -f2)
  selected_ssid=$(echo "$networks" | dmenu -i -p "Select a network:")
  if [ -z "$selected_ssid" ]; then
    echo "No network selected. Going back to main menu."
    return
  fi
  connection_status=$(wpa_cli -i $interface status | grep 'wpa_state=' | cut -d= -f2)
  if [ "$connection_status" = "COMPLETED" ]; then
    wpa_cli -i $interface disconnect
  fi
  reconfigure_wpa_and_connect
}

# Function to restart dhcpcd.service
restart_dhcp_service() {
  echo 'Restarting dhcpd.service...'
  sudo systemctl restart dhcpcd.service
  if [ $? -ne 0 ]; then
    echo 'Failed to restart dhcpcd.service'
    exit 1
  fi
  until systemctl is-active --quiet dhcpcd.service; do sleep 1; done
  echo 'dhcpd.service restarted successfully'
}

# Function to display current wifi connection
display_current_wifi() {
  current_ssid=$(wpa_cli -i $interface status | awk -F= '$1=="ssid" {print $2}')
  echo "Connected to: $current_ssid"
}

# Function to disconnect from current wifi
disconnect_wifi() {
  echo 'Requesting root password to disconnect...'
  wpa_cli -i $interface disconnect
  if [ $? -ne 0 ]; then
    echo 'Failed to disconnect.'
    exit 1
  fi
  echo 'Successfully disconnected.'
}

# Function to connect to a saved wifi network
reconfigure_wpa_and_connect() {
  wpa_cli -i $interface reconfigure
  if [ $? -ne 0 ]; then
    echo 'Failed to reconfigure wpa_supplicant. Exiting.'
    exit 1
  fi
  # Get the network id of the selected network
  net_id=$(wpa_cli -i $interface list_networks | grep "$selected_ssid" | cut -f 1)
  # Use wpa_cli to select the network
  wpa_cli -i $interface select_network $net_id
  sleep 3
}

# Function to connect to a new wifi network and backup wpa_supplicant.conf
backup_update_wpa_and_connect() {
  terminal=$(get_terminal)
  $terminal -e bash -c "\
    backup_wpa_config;
    echo 'Please type your passphrase for $selected_ssid...';
    wpa_passphrase \"\$0\" 2>&1 | grep -v 'reading passphrase from stdin' | sudo tee -a /etc/wpa_supplicant/wpa_supplicant.conf > /dev/null;
    if [ \$? -ne 0 ]; then echo 'Failed to update wpa_supplicant.conf'; exit 1; fi;
    echo 'Connecting to $selected_ssid...';
    restart_dhcp_service;
    sleep 5;
    wait_for_connection \$1 \$0;
    test_connection \$1 \$0;" "$selected_ssid" "$interface"
    sleep 3
}

export -f wait_for_connection restore_wpa_supplicant_conf backup_update_wpa_and_connect reconfigure_wpa_and_connect display_saved_networks restart_dhcp_service is_ssid_in_wpa_supplicant backup_wpa_config display_current_wifi disconnect_wifi toggle_wifi get_wireless_interface

# Main function
while true; do
  interface=$(get_wireless_interface)
  wifi_state=$(ip link show $interface | grep -q 'UP' && echo 'Off' || echo 'On')

  selected_option=$(echo -e "$(display_current_wifi)\nTurn Wifi $wifi_state\nScan for WiFi Networks\nSaved Networks" | dmenu -i -p "Select an option:")

  if [[ -z "$selected_option" ]]; then
    exit 0
  elif [[ $selected_option == "Turn Wifi $wifi_state" ]]; then
    toggle_wifi $interface
  elif [[ $selected_option == "Saved Networks" ]]; then
    display_saved_networks
  elif [[ $selected_option == "Scan for WiFi Networks" ]]; then
  wpa_cli -i $interface scan
  (echo "  Scanning for available networks... " | dmenu -p "Status") &
  dmenu_pid=$!
  sleep 5 && xdotool key Escape &
  wait $dmenu_pid
  ssid=$(wpa_cli -i $interface scan_results | awk 'NR>2 {print $NF}')
  if [ -z "$ssid" ]; then
    echo "no networks found. exiting."
    continue
  fi
  selected_ssid=$(echo "$ssid" | dmenu -i -p "Select a network:")
  if [ -z "$selected_ssid" ]; then
    echo "No network selected. Exiting."
    continue
  fi
  connection_status=$(wpa_cli -i $interface status | grep 'wpa_state=' | cut -d= -f2)
  if [ "$connection_status" = "COMPLETED" ]; then
    wpa_cli -i $interface disconnect
  fi
  if is_ssid_in_wpa_supplicant "$selected_ssid"; then
    reconfigure_wpa_and_connect
  else
    backup_update_wpa_and_connect
  fi
  else
    echo "Invalid option selected. Going back to main menu."
  fi
done
