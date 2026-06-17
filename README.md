# Screenplay Prompt

A screenplay-themed shell prompt that transforms your terminal into a movie script.

## Features

- **Slugline-style prompts** with INT./EXT. locations
- **Dynamic time of day** (DAY/NIGHT based on system time)
- **Random scene transitions** (CUT TO:, DISSOLVE TO:, FADE TO:, etc.)
- **Customizable locations** for your home directory
- **Title page** on terminal startup
- **Fully customizable** via simple text files

## Installation

### Bash

Add to your `~/.bashrc`:

```bash
source /path/to/screenplay-prompt/screenplay-prompt.sh
```

### Zsh

Add to your `~/.zshrc`:

```zsh
source /path/to/screenplay-prompt/screenplay-prompt.sh
```

## Example Output

```
                                                    CUT TO:
INT. RICK'S - NIGHT

$ cd projects
                                              DISSOLVE TO:
INT. /HOME/RICK/PROJECTS - NIGHT

$ 
```

## Customization

All configuration files are stored in `~/.config/screenplay/` by default. Update location with:

```bash
export SCREENPLAY_CONFIG="$HOME/.screenplay"
source screenplay-prompt.sh
```

### Locations (`~/.config/screenplay/locations`)

One location per line. Used when in your home directory:

```
INT. RICK'S
INT. BEDROOM
INT. KITCHEN
EXT. COFFEE SHOP
```

### Transitions (`~/.config/screenplay/transitions`)

One transition per line. Displayed right-aligned before each prompt:

```
CUT TO:
DISSOLVE TO:
FADE TO:
SMASH CUT TO:
```

### Title Page (`~/.config/screenplay/title`)

Centered text displayed when opening a new terminal:

```
ANNIE HALL

written by

Woody Allen
Marshall Brickman
```

**ANSI Support:** Title files can include ANSI escape codes for styling. The centering algorithm correctly handles color codes:

```
\033[1;37mYOUR TERMINAL\033[0m

written by

\033[3mYou\033[0m
```

## Theme Pairing

For the complete screenwriting experience, pair with:

- **Font**: Courier Prime (the digital screenwriting standard)
- **Color scheme**: High-contrast or minimal themes
- See `themes/` directory for WezTerm configuration

## Configuration

Set custom config directory:

```bash
export SCREENPLAY_CONFIG="$HOME/.screenplay"
source screenplay-prompt.sh
```

## Git Integration

**Note:** All git features gracefully degrade when not in a git repository.

Screenplay-prompt automatically detects git repositories and adds narrative context:

### Branch Character Introductions

When you switch branches or enter a new repo, the branch introduces itself:

```
INT. /HOME/USER/PROJECT - DAY

                   FEATURE/AUTH-REFACTOR
          (3 days old, optimistic, ready to ship)

$
```

### Repository Introductions

Entering a new git repo displays the repo's story from `.git/description`:

```
INT. /HOME/USER/MY-PROJECT - DAY

MY-PROJECT, 3 months old, a web application for task management.

$
```

To set your repo description:
```bash
echo "Your project description here" > .git/description
```

### Page Numbers

Your commit count appears as a screenplay page number:

```
                                                   PAGE 247
                                                    CUT TO:
INT. /HOME/USER/PROJECT - DAY
```

## Compatibility

- **Bash:** 3.2+ (tested on macOS default, Linux distros)
- **Platforms:** Linux (GNU), macOS (BSD), any POSIX-compliant system
- **Terminal:** Works in TTY and non-TTY environments (graceful degradation)
- **Portability:** Automatic fallback for missing `shuf` command on BSD/macOS
- **Git:** 1.7+ (optional - features disabled if git not available)

## License

MIT
