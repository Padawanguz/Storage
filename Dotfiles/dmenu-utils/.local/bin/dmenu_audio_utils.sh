#!/bin/bash

#
# This script provides a dynamic menu for managing audio settings using dmenu and PulseAudio.
# It allows you to adjust the volume, mute/unmute audio, set the default sink and source,
# and move audio streams between different sinks.
#
# The script operates in a loop, displaying a menu with several options:
# - "Adjust Volume": This option allows you to set the volume level for the default sink.
#   The current volume level is displayed next to the option in the menu.
# - "Mute" or "Unmute": This option toggles the mute status of the default sink.
#   The current mute status is displayed as the option in the menu.
# - "Set Default Sink": This option allows you to set the default audio output device.
# - "Select Source": This option allows you to set the default audio input device.
# - "Move Streams": This option allows you to move audio streams between different output devices.
#
# Dependencies:
# - dmenu: a generic menu for X
# - PulseAudio: a general purpose sound server
# - pactl: PulseAudio control tool
# - awk: text processing language
# - grep: text search utility
# - sed: stream editor for filtering and transforming text
#
# This script should be run directly from a terminal or bound to a keyboard shortcut.
# It is not intended to be sourced from other scripts or shell sessions.

function get_sinks {
  pactl list short sinks | awk '{print $2}'
}

function get_sources {
  pactl list short sources | awk '{print $2}'
}

function adjust_volume {
  # Generate a sequence of numbers from 0 to 150 in increments of 5
  volumes=$(seq 0 5 150)

  # Get the volume level
  volume=$(echo "$volumes" | dmenu -i -p "Set volume level for the default sink:")

  # Check if the user pressed Esc in dmenu
  [[ -z $volume ]] && return

  # Set the volume for the default sink
  pactl set-sink-volume @DEFAULT_SINK@ "$volume%"
  echo "Volume of the default sink set to $volume%"
}

function get_mute_status {
  # Get the name of the default sink
  default_sink=$(pactl info | grep 'Default Sink:' | cut -d ' ' -f3)

  # Check if the default sink is currently muted
  is_muted=$(pactl list sinks | grep -A 15 "$default_sink" | grep Mute | awk '{print $2}')

  if [[ $is_muted = "yes" ]]; then
    echo "Unmute"
  else
    echo "Mute"
  fi
}

function mute_unmute {
  # Get the name of the default sink
  default_sink=$(pactl info | grep 'Default Sink:' | cut -d ' ' -f3)

  # Toggle mute for the default sink
  pactl set-sink-mute "$default_sink" toggle

  # Wait for a short delay to ensure the toggle operation has completed
  sleep 0.1

  # Check if the default sink is currently muted
  is_muted=$(pactl list sinks | grep -A 15 "$default_sink" | grep Mute | awk '{print $2}')

  if [[ $is_muted = "yes" ]]; then
    # If the default sink is now muted, display a message
    echo "Muted the default sink"
  else
    # If the default sink is now unmuted, display a message
    echo "Unmuted the default sink"
  fi
}

function select_source {
  # Get the list of sources
  sources=$(get_sources)

  # Display the list of sources in dmenu
  selected_source=$(echo "$sources" | dmenu -i -p "Select an audio source:")
  [[ -z $selected_source ]] && return

  # Set the selected source as the default one
  pactl set-default-source "$selected_source"
  echo "Set $selected_source as default source"
}

function move_streams {
  # Get the list of audio sinks
  audio_sinks=$(get_sinks)

  # Get the list of playing streams and their associated applications
  IFS=$'\n'
  playing_streams=($(pactl list sink-inputs | grep -E '(Sink Input)|(application.name =)'))

  # Initialize stream info variables
  stream_id=""
  stream_app=""
  stream_info=()

  # Parse the playing_streams array
  for line in "${playing_streams[@]}"; do
    if [[ $line =~ "Sink Input #" ]]; then
      # If we have previous stream_id and stream_app, append them to stream_info
      if [[ -n $stream_id ]]; then
        stream_info+=("$stream_id: $stream_app")
      fi
      stream_id=$(echo $line | grep -oP '(?<=Sink Input #)\d+')
      stream_app=""
    elif [[ $line =~ "application.name = " ]]; then
      stream_app=$(echo $line | grep -oP '(?<=application.name = ").+(?=")')
    fi
  done

  # Handle the last stream
  if [[ -n $stream_id ]]; then
    stream_info+=("$stream_id: $stream_app")
  fi

  # Display the list of playing streams in dmenu
  selected_stream_info=$(printf '%s\n' "${stream_info[@]}" | dmenu -i -p "Select a stream to move:")
  [[ -z $selected_stream_info ]] && return

  # Extract the stream id from the selected info
  selected_stream_id=$(echo $selected_stream_info | cut -d ':' -f 1)

  # Display the list of audio sinks in dmenu
  selected_sink=$(echo "$audio_sinks" | dmenu -i -p "Select a sink for the stream:")
  [[ -z $selected_sink ]] && return

  # Move the selected stream to the selected sink
  pactl move-sink-input "$selected_stream_id" "$selected_sink"
  echo "Moved stream $selected_stream_id to sink $selected_sink"
}

function set_default_sink {
  # Get the list of audio sinks
  audio_sinks=$(get_sinks)

  # Display the list of audio sinks in dmenu
  selected_sink=$(echo "$audio_sinks" | dmenu -i -p "Select an audio sink:")
  [[ -z $selected_sink ]] && return

  # Set the selected sink as the default one
  pactl set-default-sink "$selected_sink"
  echo "Set $selected_sink as default sink"
}

function get_current_volume {
  # Get the name of the default sink
  default_sink=$(pactl info | grep 'Default Sink:' | cut -d ' ' -f3)

  # Get the current volume level of the default sink
  current_volume=$(pactl list sinks | grep -A 15 "$default_sink" | grep 'Volume:' | head -n1 | awk -F/ '{print $2}' | sed 's/ //g')

  echo "$current_volume"
}

while true; do
  # Update the mute status and current volume
  mute_status=$(get_mute_status)
  current_volume=$(get_current_volume)

  # Construct the main menu options based on the mute status and current volume
  options="Adjust Volume (Level $current_volume)\n$mute_status\nSet Default Sink\nSelect Source\nMove Streams"

  # Display the main menu
  command=$(echo -e $options | dmenu -i -p "Select an option:")

  # Check if a command was selected
  [[ -z $command ]] && exit

  case $command in
    "Adjust Volume (Level $current_volume)")
      adjust_volume
      ;;
    "Mute"|"Unmute")
      mute_unmute
      ;;
    "Set Default Sink")
      set_default_sink
      ;;
    "Select Source")
      select_source
      ;;
    "Move Streams")
      move_streams
      ;;
    *)
      echo "Invalid option."
      ;;
  esac
done
