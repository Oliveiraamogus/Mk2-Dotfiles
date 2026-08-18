#!/bin/bash
# Apply a theme by name: selector.sh <theme>
# Example: selector.sh gren

if [ -z "$1" ]; then
    echo "Usage: selector.sh <theme>"
    exit 1
fi

THEME="$1"
CONFIG_DIR="$HOME/.config"
THEME_SRC="$CONFIG_DIR/themes/${THEME}.json"
THEME_DST="$CONFIG_DIR/themes/current.json"

if [ ! -f "$THEME_SRC" ]; then
    echo "theme not implemented"
    exit 1
fi

# Resolve wallpaper (any extension matching the theme name)
shopt -s nullglob nocaseglob
wallpapers=("$CONFIG_DIR/Assets/Wallpapers/${THEME}".*)
shopt -u nullglob nocaseglob

if [ ${#wallpapers[@]} -eq 0 ]; then
    echo "theme not implemented"
    exit 1
fi
WALLPAPER="${wallpapers[0]}"

# Read colors from theme json
PRIMARY=$(grep -o '"primary": *"[^"]*"' "$THEME_SRC" | head -1 | sed 's/.*#\([0-9A-Fa-f]*\).*/\1/')
SECONDARY=$(grep -o '"secondary": *"[^"]*"' "$THEME_SRC" | head -1 | sed 's/.*#\([0-9A-Fa-f]*\).*/\1/')
ACCENT=$(grep -o '"accent": *"[^"]*"' "$THEME_SRC" | head -1 | sed 's/.*"\([^"]*\)".*/\1/')
# colors.background is second "background" key (#AARRGGBB -> #RRGGBBAA for CSS)
BG_RAW=$(grep -o '"background": *"[^"]*"' "$THEME_SRC" | sed -n '2p' | sed 's/.*"\([^"]*\)".*/\1/')
if [ ${#BG_RAW} -eq 9 ]; then
    BG_COLOR="#${BG_RAW:3}${BG_RAW:1:2}"
else
    BG_COLOR="$BG_RAW"
fi

# Wallpaper
hyprctl hyprpaper wallpaper ",$WALLPAPER"

# Border colors (Lua config: hyprctl keyword no longer applies)
hyprctl eval "hl.config({ general = { col = { active_border = 'rgb($PRIMARY)', inactive_border = 'rgb($SECONDARY)' } } })"

# Anyrun colors (accent + background from theme)
ANYRUN_CSS="$CONFIG_DIR/anyrun/style.css"
sed -i "s|^@define-color accent .*|@define-color accent $ACCENT;|" "$ANYRUN_CSS"
sed -i "s|^@define-color bg-color .*|@define-color bg-color $BG_COLOR;|" "$ANYRUN_CSS"

# Set current theme
cp "$THEME_SRC" "$THEME_DST"
