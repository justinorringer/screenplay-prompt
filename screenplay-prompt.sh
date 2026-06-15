#!/bin/bash
# screenplay-prompt.sh
# A screenplay-themed shell prompt plugin
# Configuration directory
SCREENPLAY_CONFIG="${SCREENPLAY_CONFIG:-$HOME/.config/screenplay}"
SCREENPLAY_LOCATIONS="$SCREENPLAY_CONFIG/locations"
SCREENPLAY_TRANSITIONS="$SCREENPLAY_CONFIG/transitions"
SCREENPLAY_TITLE="$SCREENPLAY_CONFIG/title"

# Function to determine DAY or NIGHT based on time
__screenplay_time() {
    local hour=$(date +%H)
    if [ $hour -ge 6 ] && [ $hour -lt 18 ]; then
        echo "DAY"
    else
        echo "NIGHT"
    fi
}

# Function to get random location from file
__screenplay_random_location() {
    if [ -f "$SCREENPLAY_LOCATIONS" ]; then
        shuf -n 1 "$SCREENPLAY_LOCATIONS"
    else
        echo "INT. RICK'S"
    fi
}

# Function to get random transition
__screenplay_random_transition() {
    if [ -f "$SCREENPLAY_TRANSITIONS" ]; then
        shuf -n 1 "$SCREENPLAY_TRANSITIONS"
    else
        echo "CUT TO:"
    fi
}

# Function to format path for slugline
__screenplay_location() {
    if [ "$PWD" = "$HOME" ]; then
        __screenplay_random_location
    else
        local path=$(echo "$PWD" | tr "[:lower:]" "[:upper:]")
        echo "INT. $path"
    fi
}

# Function to right-align transition
__screenplay_transition() {
    local cols=$(tput cols)
    local text=$(__screenplay_random_transition)
    local padding=$((cols - ${#text}))
    printf "%${padding}s%s" "" "$text"
}

# Function to display centered title page
__screenplay_title_page() {
    local cols=$(tput cols)
    local lines=$(tput lines)

    # Clear screen
    clear

    # Count lines in title
    local title_lines=0
    if [ -f "$SCREENPLAY_TITLE" ]; then
        title_lines=$(wc -l < "$SCREENPLAY_TITLE")
    else
        title_lines=5  # Default title has 5 lines
    fi

    # Calculate vertical centering
    local start_line=$(( (lines - title_lines) / 2 ))
    [ $start_line -lt 0 ] && start_line=0

    # Move to starting position
    tput cup $start_line 0

    # Read title page and center each line
    if [ -f "$SCREENPLAY_TITLE" ]; then
        while IFS= read -r line; do
            local len=${#line}
            local padding=$(( (cols - len) / 2 ))
            printf "%${padding}s%s\n" "" "$line"
        done < "$SCREENPLAY_TITLE"
    else
        # Default title page
        local title="YOUR TERMINAL"
        local padding=$(( (cols - ${#title}) / 2 ))
        printf "%${padding}s%s\n\n" "" "$title"

        local written="written by"
        padding=$(( (cols - ${#written}) / 2 ))
        printf "%${padding}s%s\n\n" "" "$written"

        local author="$USER"
        padding=$(( (cols - ${#author}) / 2 ))
        printf "%${padding}s%s\n" "" "$author"
    fi

    # Move cursor to bottom of screen for prompt
    tput cup $((lines - 3)) 0
}

# Set the prompt
# Format:
#                                                    CUT TO:
# INT. LOCATION - DAY
#
# $
PS1='\[\033[01;37m\]$(__screenplay_transition)\[\033[0m\]\n\[\033[01;37m\]$(__screenplay_location) - $(__screenplay_time)\[\033[0m\]\n\n\$ '

# Display title page on first load (only in interactive shells)
if [ -z "$SCREENPLAY_TITLE_SHOWN" ] && [ "$PS1" ]; then
    export SCREENPLAY_TITLE_SHOWN=1
    __screenplay_title_page
fi
