#!/bin/bash
# git-description-sync.sh
# Auto-sync .git/description from GitHub remote
# Install: cp git-description-sync.sh ~/.bashrc.d/

# Sync function
git-description-sync() {
    # Check if in git repo
    if ! git rev-parse --git-dir >/dev/null 2>&1; then
        echo "Error: Not a git repository" >&2
        return 1
    fi

    # Check if gh CLI installed
    if ! command -v gh >/dev/null 2>&1; then
        # Silently skip if gh not available
        return 1
    fi

    # Get description from GitHub
    local description=$(gh repo view --json description --template '{{.description}}' 2>/dev/null)

    if [ -z "$description" ]; then
        # No description on remote, skip silently
        return 1
    fi

    # Write to .git/description
    local git_dir=$(git rev-parse --git-dir)
    echo "$description" > "$git_dir/description"
}

# Track last repo to avoid duplicate syncs
__GIT_DESC_LAST_REPO=""

# Auto-sync on directory change
__git_description_auto_sync() {
    # Only run in git repos
    git rev-parse --git-dir >/dev/null 2>&1 || return

    # Get repo root
    local repo_root=$(git rev-parse --show-toplevel 2>/dev/null)
    [ -z "$repo_root" ] && return

    # Skip if same repo as last check
    [ "$repo_root" = "$__GIT_DESC_LAST_REPO" ] && return
    __GIT_DESC_LAST_REPO="$repo_root"

    # Check if description needs sync
    local desc_file="$repo_root/.git/description"
    if [ ! -f "$desc_file" ] || grep -q "^Unnamed repository" "$desc_file" 2>/dev/null; then
        # Has placeholder or missing - sync in background
        (git-description-sync >/dev/null 2>&1 &)
    fi
}

# Hook into PROMPT_COMMAND
if [[ "$PROMPT_COMMAND" != *"__git_description_auto_sync"* ]]; then
    PROMPT_COMMAND="__git_description_auto_sync${PROMPT_COMMAND:+; $PROMPT_COMMAND}"
fi
