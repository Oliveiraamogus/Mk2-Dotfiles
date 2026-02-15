#!/bin/bash
pkill waybar
cp /home/manel/.config/waybar/style_light.css /home/manel/.config/waybar/style.css
hyprctl hyprpaper wallpaper "eDP-1,/home/manel/backgrounds/b.png"
hyprctl hyprpaper wallpaper "HDMI-A-1,/home/manel/backgrounds/b.png"
exec waybar
exit
