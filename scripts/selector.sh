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

# Read primary / secondary from theme json (#RRGGBB -> RRGGBB)
PRIMARY=$(grep -o '"primary": *"[^"]*"' "$THEME_SRC" | head -1 | sed 's/.*#\([0-9A-Fa-f]*\).*/\1/')
SECONDARY=$(grep -o '"secondary": *"[^"]*"' "$THEME_SRC" | head -1 | sed 's/.*#\([0-9A-Fa-f]*\).*/\1/')

# Wallpaper
hyprctl hyprpaper wallpaper ",$WALLPAPER"

# Border colors
hyprctl keyword general:col.active_border "rgb($PRIMARY)"
hyprctl keyword general:col.inactive_border "rgb($SECONDARY)"

# Kitty theme — pick one and uncomment:
# kitten theme 'Base2Tone Field Dark'
# kitten theme 'Breath2'

# Set current theme
cp "$THEME_SRC" "$THEME_DST"
