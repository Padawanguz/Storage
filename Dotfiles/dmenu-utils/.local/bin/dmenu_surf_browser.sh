#!/bin/bash

# Constants
BOOKMARKS_FILE="$HOME/.surf/bookmarks.txt"
HISTORY_FILE="$HOME/.surf/history.txt"
DMENU_PROMPT="Surf to:"
NO_ACTIVE_WINDOW="No active surf window."
SEARCH_ENGINE="https://www.google.com/search?q="

# Ensure bookmarks and history files exist
mkdir -p "$(dirname "${BOOKMARKS_FILE}")"
touch "${BOOKMARKS_FILE}"
touch "${HISTORY_FILE}"

# Check if surf command is available
if ! command -v surf &> /dev/null
then
    echo "surf command could not be found"
    exit
fi

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
        echo "$url" >> "${BOOKMARKS_FILE}"
        echo "Bookmark added: $url"
    else
        echo "$NO_ACTIVE_WINDOW"
    fi
}

# Edit bookmarks file
edit_bookmarks() {
    st -e bash -c "vim ${BOOKMARKS_FILE}"
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

# Add a URL to the history
add_to_history() {
    url=$1
    datetime=$(date "+%Y-%m-%d %H:%M:%S")
    echo "$datetime - $url" >> "$HISTORY_FILE"
}

# Clear history
clear_history() {
    echo -n "" > "$HISTORY_FILE"
    echo "History cleared."
}

# Open history file
open_history() {
    st -e bash -c "vim ${HISTORY_FILE}"
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

# Main function
surf_to() {
    menu_option=$(echo -e "Add Bookmark\nBookmarks\nHistory\nActions" | dmenu -i -p "${DMENU_PROMPT}")

    case "$menu_option" in
        "Add Bookmark")
            add_bookmark
            ;;
        "Bookmarks")
            bookmark_option=$(echo -e "Edit Bookmarks\n$(sort "${BOOKMARKS_FILE}")" | dmenu -i -p "Select a bookmark or edit bookmarks:")
            if [ "$bookmark_option" = "Edit Bookmarks" ]; then
                edit_bookmarks
            elif [ -n "$bookmark_option" ]; then
                add_to_history "$bookmark_option"
                surf "$bookmark_option"
            fi
            ;;
        "History")
            history_option=$(echo -e "Clear History\nOpen History\n$(tac "${HISTORY_FILE}" | awk '{gsub(/.* - /,"")}1')" | dmenu -i -p "Select a history item, clear history or open history:")
            if [ "$history_option" = "Clear History" ]; then
                clear_history
            elif [ "$history_option" = "Open History" ]; then
                open_history
            elif [ -n "$history_option" ]; then
                surf "$(echo "$history_option" | cut -d' ' -f2-)"
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
                            add_to_history "$url"
                            surf "$url"
                        else
                            search_query=$(echo "$url" | xargs)  # xargs trims leading/trailing whitespace
                            search_url=$(search_url "$search_query")
                            add_to_history "$search_url"
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
        *)
            if [ -n "$menu_option" ]; then
                if is_valid_url "$menu_option"; then
                    add_to_history "$menu_option"
                    surf "$menu_option"
                else
                    search_query=$(echo "$menu_option" | xargs)  # xargs trims leading/trailing whitespace
                    search_url=$(search_url "$search_query")
                    add_to_history "$search_url"
                    surf "$search_url"
                fi
            fi
            ;;
    esac
}

surf_to
