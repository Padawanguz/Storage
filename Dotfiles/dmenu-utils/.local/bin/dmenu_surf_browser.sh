#!/bin/bash
# set -x
# exec 2>> debug.log
# export PS4='+[$(date "+%Y-%m-%d %H:%M:%S")] : '

# Constants
BOOKMARKS_FILE="$HOME/.surf/bookmarks.csv"
HISTORY_FILE="$HOME/.surf/history.csv"
DMENU_PROMPT="Surf to:"
NO_ACTIVE_WINDOW="No active surf window."
# SEARCH_ENGINE="https://www.google.com/search?q="
SEARCH_ENGINE="https://duckduckgo.com/?q="
PID_FILE="/tmp/surf_monitor.pid"

# Ensure bookmarks and history files exist
mkdir -p "$(dirname "${BOOKMARKS_FILE}")"
touch "${BOOKMARKS_FILE}"
touch "${HISTORY_FILE}"

# Function to log a URL to HISTORY_FILE
log_url() {
    local current_url="$1"
    local date=$(date "+%Y-%m-%d")
    local time=$(date "+%H:%M:%S")
    if [ -z "$current_url" ] || [[ "$current_url" == *"_SURF_URI:  not found"* ]]; then
        return
    fi
    echo "$date,$time,$current_url" >> "$HISTORY_FILE"
}

# Check if required commands are available
for cmd in "surf" "xdotool" "xprop"; do
    if ! command -v $cmd &> /dev/null; then
        echo "$cmd command could not be found"
        exit 1
    fi
done

# Get the URL of the current active surf window
get_surf_url() {
    active_window_id=$(xdotool getactivewindow)
    window_class=$(xprop -id "$active_window_id" WM_CLASS)
    if [[ $window_class == *"surf"* ]]; then
        xprop -id "$active_window_id" _SURF_URI | cut -d '"' -f 2
    else
        echo ""
    fi
}

# Add a bookmark
add_bookmark() {
    url=$(get_surf_url)
    if [ -n "$url" ]; then
        # Get the current timestamp
        timestamp=$(date +"%Y-%m-%d %H:%M:%S")

        # Get optional tags from the user via dmenu
        tags=$(echo "" | dmenu -p "Enter tags for this bookmark (comma separated):")

        # Get optional notes from the user via dmenu
        notes=$(echo "" | dmenu -p "Enter any notes for this bookmark:")

        # Check if the CSV file exists and has header; if not, create it
        if [ ! -f "${BOOKMARKS_FILE}" ]; then
            echo "Timestamp,URL,Tags,Notes" > "${BOOKMARKS_FILE}"
        fi

        # Append the new bookmark to the CSV file
        echo "\"$timestamp\",\"$url\",\"$tags\",\"$notes\"" >> "${BOOKMARKS_FILE}"

        # Notify the user (you could use dmenu here as well)
        echo "Bookmark added: $url" | dmenu
    else
        # Notify the user that no active window is present
        echo "No active surf window found." | dmenu
    fi
}

# Edit bookmarks file
edit_bookmarks() {
    st -e bash -c "$EDITOR ${BOOKMARKS_FILE}"
}

# Copy current URL to clipboard
copy_url_to_clipboard() {
    url=$(get_surf_url)
    if [ -n "$url" ]; then
        echo -n "$url" | xclip -selection clipboard
        echo "URL copied to clipboard: $url"
    else
        echo "$NO_ACTIVE_WINDOW"
    fi
}

# Get URL from clipboard
get_url_from_clipboard() {
    xclip -selection clipboard -o
}

is_valid_url() {
    url=$(echo "$1" | sed 's:/*$::')  # Remove trailing slashes
    if echo "$url" | grep -P '^.*\.(com|net|org|edu|gov|mil|int|eu|asia|cat|coop|info|jobs|mobi|name|post|pro|tel|travel|arpa|ac|ad|ae|af|ag|ai|al|am|an|ao|aq|ar|as|at|au|aw|ax|az|ba|bb|bd|be|bf|bg|bh|bi|bj|bm|bn|bo|br|bs|bt|bv|bw|by|bz|ca|cc|cd|cf|cg|ch|ci|ck|cl|cm|cn|co|cr|cu|cv|cx|cy|cz|de|dj|dk|dm|do|dz|ec|ee|eg|er|es|et|eu|fi|fj|fk|fm|fo|fr|ga|gb|gd|ge|gf|gg|gh|gi|gl|gm|gn|gp|gq|gr|gs|gt|gu|gw|gy|hk|hm|hn|hr|ht|hu|id|ie|il|im|in|io|iq|ir|is|it|je|jm|jo|jp|ke|kg|kh|ki|km|kn|kp|kr|kw|ky|kz|la|lb|lc|li|lk|lr|ls|lt|lu|lv|ly|ma|mc|md|me|mg|mh|mk|ml|mm|mn|mo|mp|mq|mr|ms|mt|mu|mv|mw|mx|my|mz|na|nc|ne|nf|ng|ni|nl|no|np|nr|nu|nz|om|pa|pe|pf|pg|ph|pk|pl|pm|pn|pr|ps|pt|pw|py|qa|re|ro|rs|ru|rw|sa|sb|sc|sd|se|sg|sh|si|sj|Ja|sk|sl|sm|sn|so|sr|ss|st|su|sv|sx|sy|sz|tc|td|tf|tg|th|tj|tk|tl|tm|tn|to|tp|tr|tt|tv|tw|tz|ua|ug|uk|us|uy|uz|va|vc|ve|vg|vi|vn|vu|wf|ws|ye|yt|yu|za|zm|zw).*' > /dev/null || echo "$url" | grep -P '^(http:\/\/)?[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}(:[0-9]{1,5})?$' > /dev/null; then
        return 0  # valid
    else
        return 1  # invalid
    fi
}

# Search for a query using the search engine
search_url() {
    query=$1
    echo "${SEARCH_ENGINE}${query}"
}

# Clear history
clear_history() {
    echo -n "" > "$HISTORY_FILE"
    echo "History cleared."
}

# Open history file
open_history() {
    st -e bash -c "$EDITOR ${HISTORY_FILE}"
}

# Clear cookies
clear_cookies() {
    COOKIES_FILE="$HOME/.surf/cookies.txt"
    if [ -f "$COOKIES_FILE" ]; then
        echo -n "" > "$COOKIES_FILE"
        echo "Cookies cleared."
    else
        echo "Cookies file does not exist."
    fi
}

# Clear cache
clear_cache() {
    CACHE_DIR="$HOME/.surf/cache"
    if [ -d "$CACHE_DIR" ]; then
        rm -r "$CACHE_DIR/*"
        echo "Cache cleared."
    else
        echo "Cache directory does not exist."
    fi
}

# Function to get all Surf window IDs
get_all_surf_window_ids() {
    xdotool search --class "surf"
}

# Function to monitor URL changes for a single Surf window
monitor_single_window() {
    trap "echo 'Terminating monitoring for window $1'; exit" SIGTERM
    local surf_window_id=$1
    local last_url=""
    xprop -id "$surf_window_id" -spy _SURF_URI 2>/dev/null | \
    while read -r line; do
        local current_url=$(echo "$line" | cut -d '"' -f 2)
        if [ "$current_url" != "$last_url" ]; then
            log_url "$current_url"
            last_url="$current_url"
        fi
    done
}

# Function to monitor URL changes
monitor_url_changes() {
    declare -A last_logged_url
    declare -A active_subshells
    local wait_time=0  # Initialize the wait_time variable

    while true; do
        local surf_window_ids=$(get_all_surf_window_ids)

        if [ -z "$surf_window_ids" ]; then
            sleep 1  # Sleep for 1 second
            ((wait_time++))  # Increment the wait_time variable

            # Check if the wait_time has reached 10 seconds
            if [ $wait_time -ge 10 ]; then
                echo "No active Surf instances found for 10 seconds. Exiting monitor."
                exit 0  # Exit the script
            else
                continue  # Skip the rest of the loop and continue
            fi
        else
            wait_time=0  # Reset the wait_time variable if Surf instances are found
        fi

        for surf_window_id in $surf_window_ids; do
            if [ -z "${active_subshells[$surf_window_id]}" ]; then
                (
                    monitor_single_window "$surf_window_id"
                ) &
                active_subshells[$surf_window_id]=$!
            fi
        done

        # Remove closed windows and dead subprocesses from active_subshells
        for id in "${!active_subshells[@]}"; do
            if ! [[ $surf_window_ids =~ $id ]] || ! kill -0 "${active_subshells[$id]}" 2>/dev/null; then
                # If subprocess is alive, kill it
                kill "${active_subshells[$id]}" 2>/dev/null

                # Remove from active_subshells
                unset active_subshells["$id"]
            fi
        done

        sleep 5  # Sleep for 5 seconds before the next iteration
    done
}

# Function to launch the monitor script
launch_monitor() {
    # Check if a PID file exists
    if [ -f "$PID_FILE" ]; then
        old_pid=$(cat "$PID_FILE")
        # Check if the old process is still running
        if kill -0 "$old_pid" 2>/dev/null; then
            echo "An instance of surf_monitor is already running."
            return
        else
            # If the old process is not running, remove the stale PID file
            rm -f "$PID_FILE"
        fi
    fi

    # Launch surf_monitor.sh and store its PID
    monitor_url_changes &
    echo $! > "$PID_FILE"
}

# Function to get bookmark options
get_bookmark_options() {
    awk -F '","' '{print $2}' "${BOOKMARKS_FILE}" | sort
}

# Function to get history options
get_history_options() {
    awk -F, '{print $3}' "${HISTORY_FILE}" | sort
}

# Function to get filtered options
filtered_options() {
    local bookmark_options=$(get_bookmark_options)
    local history_options=$(get_history_options)

    # Filter out duplicates
    local filtered_history_urls=$(echo -e "$history_options" | sort -u | grep -vxF -f <(echo -e "$bookmark_options"))

    # Add prefixes only if options exist
    local bookmark_prefixed=$( [[ -n "$bookmark_options" ]] && echo -e "$bookmark_options" | awk '{print "Bookmark: " $0}')
    local filtered_history_prefixed=$( [[ -n "$filtered_history_urls" ]] && echo -e "$filtered_history_urls" | awk '{print "History: " $0}')

    echo -e "$bookmark_prefixed\n$filtered_history_prefixed"
}

# Main function
surf_to() {
    # Use the new function to get filtered options for the main menu
    local all_options=$(filtered_options)

    # Build the main menu string
    local menu_string="Add Bookmark\nBookmarks\nHistory\nActions"

    # Only add the separator and options if there are any
    if [[ -n "$all_options" ]]; then
        menu_string+="\n----\n$all_options"
    fi

    # Main menu
    menu_option=$(echo -e "$menu_string" | dmenu -i -l 20 -p "${DMENU_PROMPT}")

    case "$menu_option" in
        "Add Bookmark")
            add_bookmark
            ;;
        "Bookmarks")
            bookmark_submenu_options=$(echo -e "Edit Bookmarks\n$(get_bookmark_options)")
            bookmark_option=$(echo -e "$bookmark_submenu_options" | dmenu -i -l 10 -p "Bookmarks:")
            if [ "$bookmark_option" = "Edit Bookmarks" ]; then
                edit_bookmarks
            elif [ -n "$bookmark_option" ]; then
                launch_monitor &
                surf "$bookmark_option"
            fi
            ;;
        "History")
            history_submenu_options=$(echo -e "Clear History\nOpen History\n$(get_history_options)")
            history_option=$(echo -e "$history_submenu_options" | dmenu -i -l 10 -p "History:")
            if [ "$history_option" = "Clear History" ]; then
                clear_history
            elif [ "$history_option" = "Open History" ]; then
                open_history
            elif [ -n "$history_option" ]; then
                launch_monitor &
                surf "$history_option"
            fi
            ;;
        "Actions")
            action_option=$(echo -e "Copy URL to Clipboard\nPaste from Clipboard\nClear Cookies\nClear Cache" | dmenu -i -p "Select an action:")
            case "$action_option" in
                "Copy URL to Clipboard")
                    copy_url_to_clipboard
                    ;;
                "Paste from Clipboard")
                    url=$(get_url_from_clipboard)
                    if [ -n "$url" ]; then
                        if is_valid_url "$url"; then
                            launch_monitor &
                            surf "$url"
                        else
                            search_query=$(echo "$url" | xargs)  # xargs trims leading/trailing whitespace
                            search_url=$(search_url "$search_query")
                            launch_monitor &
                            surf "$search_url"
                        fi
                    fi
                    ;;
                "Clear Cookies")
                    clear_cookies
                    ;;
                "Clear Cache")
                    clear_cache
                    ;;
            esac
            ;;
        "Bookmark:"*)
            url=${menu_option#Bookmark: }
            launch_monitor &
            surf "$url"
            ;;
        "History:"*)
            url=${menu_option#History: }
            launch_monitor &
            surf "$url"
            ;;
        "!"*)
            # If the option starts with "!", treat it as a search query
            search_query=${menu_option#!}
            search_url=$(search_url "$search_query")
            launch_monitor &
            surf "$search_url"
            ;;
        *)
            if [ -n "$menu_option" ]; then
                if is_valid_url "$menu_option"; then
                    launch_monitor &
                    surf "$menu_option"
                else
                    search_query=$(echo "$menu_option" | xargs)  # Remove leading/trailing whitespace
                    search_url=$(search_url "$search_query")
                    launch_monitor &
                    surf "$search_url"
                fi
            fi
            ;;
    esac
}

# Run the main function and then the monitor
surf_to
