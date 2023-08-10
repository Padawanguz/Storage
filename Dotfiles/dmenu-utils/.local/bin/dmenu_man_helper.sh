#!/bin/bash
set -x
set -e
display_cheatsheet() {
  case $1 in
   "Vim Cheatsheet")
      cheatsheet=$(cat "$HOME/Storage/Various/vim_cheatsheet.txt")
      ;;
    "Git Cheatsheet")
      cheatsheet=$(cat "$HOME/Storage/Various/git_cheatsheet.txt")
      ;;
    "Arch Cheatsheet")
      cheatsheet=$(cat "$HOME/Storage/Various/arch_cheatsheet.txt")
      ;;
  esac

  # Show the cheatsheet in dmenu
  echo "$cheatsheet" | dmenu -l 20 -i -p "$1: "
}

cheatsheet_menu() {

  # Select a cheat sheet using dmenu
  selected_cheatsheet=$(echo -e "Vim Cheatsheet\nGit Cheatsheet\nArch Cheatsheet" | dmenu -i -p 'Select a Cheat Sheet: ')

  # Check if dmenu was cancelled by pressing Esc
  if [ "$?" -eq 1 ]; then
    return
  fi

  # Display the selected cheat sheet
  display_cheatsheet "$selected_cheatsheet"

  # Return to the cheat sheet menu
  cheatsheet_menu
}

display_man() {
  # Options for the main menu
  main_menu_options="View Man Pages\nView Cheat Sheets"

  # Select an option from the main menu
  selected_option=$(echo -e "View Man Pages\nView Cheat Sheets" | dmenu -i -p 'Select an Option: ')

  # Check if dmenu was cancelled by pressing Esc
  if [ "$?" -eq 1 ]; then
    echo "Exiting..."
    exit 0
  fi

  case $selected_option in
    "View Man Pages")
      # Gather list of all unique commands from man pages
      commands=$(man -k . | awk '{print $1}' | sort | uniq)
      selected_command=$(echo "$commands" | dmenu -i -p 'Command: ')
      # Check if dmenu was cancelled by pressing Esc
      if [ "$?" -eq 1 ]; then
        display_man
        return
      fi
      st -e bash -c "man $selected_command"
      ;;
    "View Cheat Sheets")
      cheatsheet_menu
      ;;
  esac

  # Return to the main menu
  display_man
}

# Start the script
display_man
