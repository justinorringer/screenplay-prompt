#!/bin/bash
# screenplay-prompt.sh
# A screenplay-themed shell prompt plugin
# Configuration directory
SCREENPLAY_CONFIG="${SCREENPLAY_CONFIG:-$HOME/.config/screenplay}"
SCREENPLAY_LOCATIONS="$SCREENPLAY_CONFIG/locations"
SCREENPLAY_TRANSITIONS="$SCREENPLAY_CONFIG/transitions"
SCREENPLAY_TITLE="$SCREENPLAY_CONFIG/title"

# Detect shuf availability once at source time
__SCREENPLAY_HAS_SHUF=false
command -v shuf >/dev/null 2>&1 && __SCREENPLAY_HAS_SHUF=true

# Git integration - per-directory repo detection
__SCREENPLAY_IN_GIT_REPO="unknown"

__screenplay_check_git_repo() {
    if git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
        __SCREENPLAY_IN_GIT_REPO="true"
    else
        __SCREENPLAY_IN_GIT_REPO="false"
    fi
}

# Calculate time since last commit on branch
__screenplay_branch_age() {
    local branch="$1"
    local commit_date=$(git log -1 --format=%ct "$branch" 2>/dev/null)
    [ -z "$commit_date" ] && echo "untouched" && return

    local age_days=$(( ($(date +%s) - commit_date) / 86400 ))

    if [ $age_days -eq 0 ]; then
        echo "last updated today"
    elif [ $age_days -eq 1 ]; then
        echo "last updated yesterday"
    elif [ $age_days -lt 8 ]; then
        echo "last updated $age_days days ago"
    elif [ $age_days -lt 30 ]; then
        echo "last updated $(( age_days / 7 )) weeks ago"
    elif [ $age_days -lt 365 ]; then
        echo "last updated $(( age_days / 30 )) months ago"
    else
        echo "last updated $(( age_days / 365 )) years ago"
    fi
}

# Assign personality based on time since last update
__screenplay_branch_personality() {
    local branch="$1"
    local commit_date=$(git log -1 --format=%ct "$branch" 2>/dev/null)
    [ -z "$commit_date" ] && echo "untouched, mysterious" && return

    local age_days=$(( ($(date +%s) - commit_date) / 86400 ))

    # Activity-based personality
    if [ $age_days -eq 0 ]; then
        echo "fresh, still warm"
    elif [ $age_days -le 2 ]; then
        echo "active, in the zone"
    elif [ $age_days -le 7 ]; then
        echo "cooling down, needs attention"
    elif [ $age_days -le 30 ]; then
        echo "patient, waiting"
    else
        echo "forgotten, gathering dust"
    fi
}

# Safe tput wrapper with validation and fallbacks
__screenplay_safe_tput() {
    local capability="$1"
    local default="$2"
    local result

    # Try tput (works in PS1 command substitution even though stdout captured)
    result=$(tput "$capability" 2>/dev/null)
    local status=$?

    # Validate: non-zero exit, empty result, or non-numeric for cols/lines
    if [ $status -ne 0 ] || [ -z "$result" ] || ! [[ "$result" =~ ^[0-9]+$ ]]; then
        echo "$default"
    else
        echo "$result"
    fi
}

# Portable random line picker (works without shuf on BSD/macOS)
__screenplay_random_line() {
    local file="$1"

    [ ! -f "$file" ] && return 1
    [ ! -s "$file" ] && return 1  # File exists but is empty

    if $__SCREENPLAY_HAS_SHUF; then
        shuf -n 1 "$file"
    else
        # Bash-native alternative using RANDOM
        local lines=()
        while IFS= read -r line; do
            [ -n "$line" ] && lines+=("$line")
        done < "$file"

        [ ${#lines[@]} -eq 0 ] && return 1

        local idx=$((RANDOM % ${#lines[@]}))
        echo "${lines[$idx]}"
    fi
}

# Calculate visible string length (strips ANSI escape sequences)
__screenplay_visible_length() {
    local str="$1"
    # Remove ANSI escape sequences using sed (more reliable than bash patterns)
    local stripped=$(echo "$str" | sed 's/\x1b\[[0-9;]*m//g')
    echo "${#stripped}"
}

# Sanitize path for safe display
__screenplay_sanitize_path() {
    local path="$1"
    local max_len=60

    # Remove control characters (ASCII 0-31 except tab/newline, and 127)
    path="${path//[$'\001'-$'\037'$'\177']/}"

    # Truncate long paths with ellipsis
    if [ ${#path} -gt $max_len ]; then
        local trim_len=$((max_len - 3))
        path="...${path: -$trim_len}"
    fi

    echo "$path"
}

# Display branch character introduction (called from PROMPT_COMMAND)
__screenplay_branch_intro() {
    [ "$__SCREENPLAY_SHOW_BRANCH_INTRO" != "true" ] && return

    local branch="$__SCREENPLAY_CACHE_BRANCH"
    local age=$(__screenplay_branch_age "$branch")
    local personality=$(__screenplay_branch_personality "$branch")

    local cols=$(__screenplay_safe_tput cols 80)
    local display_branch=$(echo "$branch" | tr "[:lower:]" "[:upper:]" | tr "/" "-")

    echo ""

    # Center branch name
    local padding=$(( (cols - ${#display_branch}) / 2 ))
    [ $padding -lt 0 ] && padding=0
    printf "%${padding}s%s\n" "" "$display_branch"

    # Center personality
    local desc="($age, $personality)"
    padding=$(( (cols - ${#desc}) / 2 ))
    [ $padding -lt 0 ] && padding=0
    printf "%${padding}s%s\n" "" "$desc"

    __SCREENPLAY_SHOW_BRANCH_INTRO=""
    __SCREENPLAY_SHOW_PAGE=""
}

# Display repo introduction (called from PROMPT_COMMAND)
__screenplay_repo_intro() {
    [ "$__SCREENPLAY_SHOW_REPO_INTRO" != "true" ] && return

    local repo_root="$__SCREENPLAY_CACHE_GIT_ROOT"
    local repo_name=$(basename "$repo_root")

    # Get repo age from first commit
    local first_commit=$(git log --reverse --format=%ct 2>/dev/null | head -1)
    [ -z "$first_commit" ] && first_commit=$(date +%s)  # Fallback for brand new repos
    local age_days=$(( ($(date +%s) - first_commit) / 86400 ))

    local age_text
    if [ $age_days -lt 30 ]; then
        age_text="$age_days days old"
    elif [ $age_days -lt 365 ]; then
        age_text="$(( age_days / 30 )) months old"
    else
        age_text="$(( age_days / 365 )) years old"
    fi

    # Get description from .git/description
    local desc=$(cat "$repo_root/.git/description" 2>/dev/null)
    if [[ "$desc" == "Unnamed repository"* ]] || [ -z "$desc" ]; then
        desc="dim, strong, with a unibrow, meets a YOUNG LATINO boxer center ring"
    fi

    # Always format as: NAME, AGE, DESCRIPTION
    local display_name=$(echo "$repo_name" | tr "[:lower:]" "[:upper:]" | tr "_" "-")
    local output="$display_name, $age_text"
    [ -n "$desc" ] && output="$output, $desc"

    if [ $repo_name == "screenplay-prompt" ]; then
        # set the introduction line to the description
        output="$desc"
    fi

    echo ""
    echo "$output."

    __SCREENPLAY_SHOW_REPO_INTRO=""
    __SCREENPLAY_SHOW_PAGE=""
}

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
    __screenplay_random_line "$SCREENPLAY_LOCATIONS" || echo "INT. RICK'S"
}

# Function to get random transition
__screenplay_random_transition() {
    __screenplay_random_line "$SCREENPLAY_TRANSITIONS" || echo "CUT TO:"
}

# Function to format path for slugline
__screenplay_location() {
    if [ "$PWD" = "$HOME" ]; then
        __screenplay_random_location
    else
        local path=$(__screenplay_sanitize_path "$PWD")
        local upper=$(echo "$path" | tr "[:lower:]" "[:upper:]")
        echo "INT. $upper"
    fi
}

# Function to get random transition text (no padding)
__screenplay_transition_text() {
    __screenplay_random_transition
}

# Function to right-align transition (for display)
__screenplay_transition() {
    local text="$1"
    [ -z "$text" ] && text=$(__screenplay_transition_text)

    local cols=$(__screenplay_safe_tput cols 80)
    local text_len=${#text}

    # Ensure padding is non-negative
    local padding=$((cols > text_len ? cols - text_len : 0))
    printf "%${padding}s%s" "" "$text"
}

# Function to display centered title page
__screenplay_title_page() {
    # Early exit for non-interactive shells
    [ -t 1 ] || return

    local cols=$(__screenplay_safe_tput cols 80)
    local lines=$(__screenplay_safe_tput lines 24)

    # Clear screen (fallback to newlines for non-ANSI terminals)
    clear 2>/dev/null || printf "\n\n\n"

    # Count lines in title
    local title_lines=0
    if [ -f "$SCREENPLAY_TITLE" ]; then
        title_lines=$(wc -l < "$SCREENPLAY_TITLE" 2>/dev/null || echo 5)
    else
        title_lines=5  # Default title has 5 lines
    fi

    # Calculate vertical centering
    local start_line=$(( (lines - title_lines) / 2 ))
    [ $start_line -lt 0 ] && start_line=0

    # Move to starting position (if tput available)
    if command -v tput >/dev/null 2>&1; then
        tput cup $start_line 0 2>/dev/null
    fi

    # Read title page and center each line
    if [ -f "$SCREENPLAY_TITLE" ]; then
        while IFS= read -r line; do
            local len=$(__screenplay_visible_length "$line")
            local padding=$(( (cols - len) / 2 ))
            [ $padding -lt 0 ] && padding=0
            printf "%${padding}s%s\n" "" "$line"
        done < "$SCREENPLAY_TITLE"
    else
        # Default title page
        local title="YOUR TERMINAL"
        local padding=$(( (cols - ${#title}) / 2 ))
        [ $padding -lt 0 ] && padding=0
        printf "%${padding}s%s\n\n" "" "$title"

        local written="written by"
        padding=$(( (cols - ${#written}) / 2 ))
        [ $padding -lt 0 ] && padding=0
        printf "%${padding}s%s\n\n" "" "$written"

        local author="$USER"
        padding=$(( (cols - ${#author}) / 2 ))
        [ $padding -lt 0 ] && padding=0
        printf "%${padding}s%s\n" "" "$author"
    fi

    # Move cursor to bottom of screen for prompt (if tput available)
    if command -v tput >/dev/null 2>&1; then
        tput cup $((lines - 3)) 0 2>/dev/null
    fi
}

# Cache variables for performance
export __SCREENPLAY_CACHE_TIME=""
export __SCREENPLAY_CACHE_TRANSITION_TEXT=""
export __SCREENPLAY_CACHE_LOCATION=""
export __SCREENPLAY_CACHE_PWD=""
export __SCREENPLAY_CACHE_BRANCH=""
export __SCREENPLAY_CACHE_GIT_ROOT=""
export __SCREENPLAY_CACHE_COMMIT_COUNT=""
export __SCREENPLAY_SHOW_BRANCH_INTRO=""
export __SCREENPLAY_SHOW_REPO_INTRO=""
export __SCREENPLAY_SHOW_PAGE=""

# Update cache (called via PROMPT_COMMAND)
__screenplay_update_cache() {
    __screenplay_check_git_repo  # Lazy session check

    # Only regenerate if directory changed
    if [ "$PWD" != "$__SCREENPLAY_CACHE_PWD" ]; then
        __SCREENPLAY_CACHE_PWD="$PWD"

        # Get git branch if in repo
        if [ "$__SCREENPLAY_IN_GIT_REPO" = "true" ]; then
            local new_branch=$(git branch --show-current 2>/dev/null)
            local new_root=$(git rev-parse --show-toplevel 2>/dev/null)

            # Branch changed - show intro and page
            if [ "$new_branch" != "$__SCREENPLAY_CACHE_BRANCH" ] && [ -n "$new_branch" ]; then
                __SCREENPLAY_SHOW_BRANCH_INTRO="true"
                __SCREENPLAY_SHOW_PAGE="true"
            fi

            # New repo entered - show repo intro and page
            if [ "$new_root" != "$__SCREENPLAY_CACHE_GIT_ROOT" ] && [ -n "$new_root" ]; then
                __SCREENPLAY_SHOW_REPO_INTRO="true"
                __SCREENPLAY_SHOW_PAGE="true"
            fi

            __SCREENPLAY_CACHE_BRANCH="$new_branch"
            __SCREENPLAY_CACHE_GIT_ROOT="$new_root"
            __SCREENPLAY_CACHE_COMMIT_COUNT=$(git rev-list --count HEAD 2>/dev/null)
        else
            __SCREENPLAY_CACHE_BRANCH=""
            __SCREENPLAY_CACHE_GIT_ROOT=""
            __SCREENPLAY_CACHE_COMMIT_COUNT=""
        fi

        __SCREENPLAY_CACHE_LOCATION=$(__screenplay_location)
        __SCREENPLAY_CACHE_TRANSITION_TEXT=$(__screenplay_transition_text)
    fi

    # Always refresh time (cheap, accurate)
    __SCREENPLAY_CACHE_TIME=$(__screenplay_time)
}

# Format cached transition with current terminal width
__screenplay_format_transition() {
    __screenplay_transition "$__SCREENPLAY_CACHE_TRANSITION_TEXT"
}

# Display page number (commit count) - integrated with transition line
__screenplay_transition_with_page() {
    local cols=$(__screenplay_safe_tput cols 80)

    # Get transition text
    local transition=$(__screenplay_format_transition)

    # Show page number only when intros showing
    if [ -n "$__SCREENPLAY_CACHE_COMMIT_COUNT" ] && [ "$__SCREENPLAY_SHOW_PAGE" = "true" ]; then
        echo ""
        local page="PAGE $__SCREENPLAY_CACHE_COMMIT_COUNT"
        local page_len=${#page}

        # Print page on left, transition stays right-aligned
        printf "%s%s\n" "$page" "${transition:$page_len}"
    else
        # Just transition
        echo "$transition"
    fi
}

# Invalidate cache on terminal resize
trap '__SCREENPLAY_CACHE_PWD=""' WINCH

# Render everything in PROMPT_COMMAND so flags work
__screenplay_render_prompt() {
    # Standard prompt line
    __screenplay_transition_with_page
    echo -e "\033[01;37m$__SCREENPLAY_CACHE_LOCATION - $__SCREENPLAY_CACHE_TIME\033[0m"

    # Conditional intros
    __screenplay_repo_intro
    __screenplay_branch_intro
}

# Hook into PROMPT_COMMAND (preserve existing value)
PROMPT_COMMAND="__screenplay_update_cache; __screenplay_render_prompt${PROMPT_COMMAND:+; $PROMPT_COMMAND}"

# Set the prompt (just the $ symbol since we render in PROMPT_COMMAND)
PS1='\$ '

# Display title page on first load (only in interactive shells)
if [ -z "$SCREENPLAY_TITLE_SHOWN" ] && [ "$PS1" ]; then
    export SCREENPLAY_TITLE_SHOWN=1
    __screenplay_title_page
fi
