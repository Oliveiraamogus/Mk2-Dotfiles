#!/bin/bash
pkill waybar
cp /home/manel/escolinha/scripts/waybar_dark/style_dark.css /home/manel/.config/waybar/style.css
hyprctl hyprpaper wallpaper "eDP-1,/home/manel/backgrounds/alena-aenami-lights1k1.jpg"
hyprctl hyprpaper wallpaper "HDMI-A-1,/home/manel/backgrounds/alena-aenami-lights1k1.jpg"
exec waybar
exit
