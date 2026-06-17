# Installation Guide

## Quick Install

### Bash

Add to your `~/.bashrc`:

```bash
source /path/to/screenplay-prompt/screenplay-prompt.sh
```

Then restart your terminal or run:

```bash
source ~/.bashrc
```

### Zsh

Add to your `~/.zshrc`:

```zsh
source /path/to/screenplay-prompt/screenplay-prompt.sh
```

Then restart your terminal or run:

```zsh
source ~/.zshrc
```

## Recommended Installation Location

Clone or copy to a permanent location:

```bash
# Option 1: Clone to ~/.screenplay-prompt
git clone <repo-url> ~/.screenplay-prompt
echo 'source ~/.screenplay-prompt/screenplay-prompt.sh' >> ~/.bashrc

# Option 2: Copy to ~/.screenplay-prompt
cp -r screenplay-prompt ~/.screenplay-prompt
echo 'source ~/.screenplay-prompt/screenplay-prompt.sh' >> ~/.bashrc
```

## Post-Installation

On first run, screenplay-prompt will automatically create:

```
~/.config/screenplay/
├── locations       # INT./EXT. locations
├── transitions     # Scene transitions
└── title          # Title page content
```

### Customize Your Title Page

Edit `~/.config/screenplay/title`:

```
ANNIE HALL

written by

Woody Allen
Marshall Brickman
```

### Add Custom Locations

Edit `~/.config/screenplay/locations`:

```
INT. RICK'S
INT. BEDROOM
INT. COFFEE SHOP
EXT. CITY STREET
```

### Customize Transitions

Edit `~/.config/screenplay/transitions`:

```
CUT TO:
DISSOLVE TO:
FADE TO:
SMASH CUT TO:
```

## Optional: Install WezTerm Theme

For the complete screenplay experience:

```bash
cp themes/wezterm-screenplay.lua ~/.config/wezterm/
ln -sf ~/.config/wezterm/wezterm-screenplay.lua ~/.config/wezterm/wezterm.lua
```

Restart WezTerm to apply.

## Troubleshooting

### Title page doesn't show

The title page only appears once per session. To see it again, run:

```bash
unset SCREENPLAY_TITLE_SHOWN
source ~/.bashrc
```

Or simply run `clear` and open a new terminal.

### Transitions not right-aligned

Make sure your terminal supports `tput cols`. Most modern terminals do. If `tput` is unavailable, the prompt automatically falls back to 80-column width.

### Non-TTY environments

Screenplay-prompt gracefully degrades in non-interactive environments (scripts, pipes, cron jobs):
- Title page is skipped
- Terminal size detection falls back to defaults (80x24)
- All features remain functional

### Missing shuf on macOS

No action needed. Screenplay-prompt automatically detects missing `shuf` command and uses a bash-native random line picker. This is common on BSD/macOS systems and is handled transparently.

### Custom config directory

Set a custom location for config files:

```bash
export SCREENPLAY_CONFIG="$HOME/.screenplay"
source screenplay-prompt.sh
```

### Empty or missing config files

All config files are optional. If missing or empty, sensible defaults are used:
- `locations`: Falls back to "INT. RICK'S"
- `transitions`: Falls back to "CUT TO:"
- `title`: Uses built-in default title page

## Uninstall

Remove from your shell RC file:

```bash
# Edit ~/.bashrc or ~/.zshrc and remove the line:
# source ~/.screenplay-prompt/screenplay-prompt.sh
```

Optionally remove config:

```bash
rm -rf ~/.config/screenplay
rm -rf ~/.screenplay-prompt
```
