#!/bin/bash
#cp /home/manel/escolinha/scripts/blu_theme/hyprland_blu.conf /home/manel/.config/hypr/hyprland.conf
hyprctl keyword general:col.active_border 'rgb(7895B4)'
hyprctl keyword general:col.inactive_border 'rgb(1e1e2e)'

kitten theme 'Atelier Lakeside Dark'

cp /home/manel/escolinha/scripts/blu_theme/style_anyrun_b.css /home/manel/.config/anyrun/style.css

hyprctl hyprpaper wallpaper "eDP-1,/home/manel/backgrounds/b.png"
hyprctl hyprpaper wallpaper "HDMI-A-1,/home/manel/backgrounds/b.png"

waybar -s /home/manel/escolinha/scripts/blu_theme/style_light.css
exit