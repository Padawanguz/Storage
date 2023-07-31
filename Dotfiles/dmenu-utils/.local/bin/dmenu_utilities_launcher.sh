
#!/bin/bash

# Array of scripts
declare -A options
options["Wifi Networks"]="$HOME/.local/bin/dmenu_wpa_supplicant.sh"
options["Bluetooth"]="$HOME/.local/bin/dmenu_bluetooth.sh"
options["Keyboards"]="$HOME/.local/bin/dmenu_keyboard_config.sh"
options["Disk Manager"]="$HOME/.local/bin/dmenu_disk_manager.sh"
options["Audio Control"]="$HOME/.local/bin/dmenu_audio_utils.sh"
options["Man Pages Helper"]="$HOME/.local/bin/dmenu_man_helper.sh"

# Generate a string with the names of the scripts
keys=""
for key in "${!options[@]}"; do
    keys+="$key\n"
done

# Use dmenu to select a script
selected=$(echo -e $keys | dmenu -i -p 'Select a script:')

# Check if selected is empty
if [[ -z $selected ]]; then
    echo "No selection"
    exit 1
fi

# Run the selected script
"${options[$selected]}"
