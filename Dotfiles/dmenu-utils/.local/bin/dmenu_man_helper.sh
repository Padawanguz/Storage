#!/bin/bash
#
# This script provides a user-friendly interface to view Unix/Linux man pages.
# It retrieves a list of all unique commands from the man pages available on the system,
# presents them in a dmenu for user selection, and then displays the man page for the selected command.
# The script also handles cases where no commands are found or no selection is made.
#
# After a man page is viewed, the script loops back to the main menu, allowing the user to
# select and view another command's man page. The script only exits when the 'dmenu' selection
# is cancelled (such as when ESC is pressed).
#
# Dependencies:
# - man: to retrieve and display man pages.
# - awk: to process the output of the 'man' command.
# - sort and uniq: to sort and remove duplicates from the command list.
# - dmenu: to present the command list in a user-friendly menu.

# Function to display man pages.
display_man() {

  # Gather list of all unique commands from man pages.
  commands=$(man -k . | awk '{print $1}' | sort | uniq)

  # If no commands found, print error message and exit.
  if [[ -z "$commands" ]]; then
    echo "No commands found. Exiting..."
    exit 1
  fi

  # Present commands in dmenu for selection.
  selected_command=$(echo "$commands" | dmenu -i -p 'Command: ')

  # Check if dmenu was cancelled.
  if [ "$?" -eq 1 ]; then
    # If dmenu was cancelled, exit the script.
    echo "Exiting..."
    exit 0
  elif [[ -z "$selected_command" ]]; then
    # If no selection made, print error message and return to the function.
    echo "No selection made. Returning to main menu..."
    display_man
  fi

  # Display man page for selected command.
  man $selected_command

  # After displaying man page, return to main menu.
  display_man
}

# Start the script.
display_man
