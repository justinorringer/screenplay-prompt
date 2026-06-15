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

## License

MIT
