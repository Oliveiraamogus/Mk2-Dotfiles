#!/bin/bash

#extract last used theme from current.json
THEME=$(grep -o '"id": *"[^"]*"' "$HOME/.config/themes/current.json" | head -1 | sed 's/.*"\([^"]*\)".*/\1/')
CONFIG_DIR="$HOME/.config"
THEME_SRC="$CONFIG_DIR/themes/current.json"
THEME_DST="$CONFIG_DIR/themes/current.json"



# Resolve wallpaper (any extension matching the theme name)
shopt -s nullglob nocaseglob
wallpapers=("$CONFIG_DIR/Assets/Wallpapers/${THEME}".*)
shopt -u nullglob nocaseglob

WALLPAPER="${wallpapers[0]}"


# Wallpaper
hyprctl hyprpaper wallpaper ",$WALLPAPER"



# Read colors from theme json
PRIMARY=$(grep -o '"primary": *"[^"]*"' "$THEME_SRC" | head -1 | sed 's/.*#\([0-9A-Fa-f]*\).*/\1/')
SECONDARY=$(grep -o '"secondary": *"[^"]*"' "$THEME_SRC" | head -1 | sed 's/.*#\([0-9A-Fa-f]*\).*/\1/')

# Border colors
hyprctl keyword general:col.active_border "rgb($PRIMARY)"
hyprctl keyword general:col.inactive_border "rgb($SECONDARY)"
