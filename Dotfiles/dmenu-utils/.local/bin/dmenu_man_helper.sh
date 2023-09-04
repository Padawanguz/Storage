#!/bin/bash

# Path to the man pages file with descriptions
MAN_PAGES_FILE="$HOME/man_pages_with_descriptions.txt"

# Function to generate the man pages file with descriptions
generate_man_pages_file() {
  apropos . | awk -F ' - ' '{print $1 " -" $2}' | sort > "$MAN_PAGES_FILE"
}

# Check if the man pages file exists, generate it if not
if [ ! -f "$MAN_PAGES_FILE" ]; then
  generate_man_pages_file
fi

# Read the man pages with descriptions from the file
man_pages_with_descriptions=$(cat "$MAN_PAGES_FILE")

# Function to prompt the user to select a man page
select_man_page() {
  echo "$man_pages_with_descriptions" | dmenu -l 20 -p "Select a man page:"
}

# Function to open the selected man page
open_man_page() {
  selected_page=$(echo "$1" | cut -d ' ' -f 1)
  st -e man "$selected_page"
}

# Main loop to handle user interactions
while true; do
  selected_item=$(select_man_page)

  # Break the loop if the user presses escape or selects nothing
  if [ -z "$selected_item" ]; then
    break
  fi

  # Prompt the user to view the man page or search again
  action=$(echo -e "View\nSearch Again" | dmenu -p "What would you like to do?")

  case "$action" in
    "View")
      open_man_page "$selected_item"
      ;;
    "Search Again")
      continue
      ;;
    *)
      break
      ;;
  esac
done
