#!/bin/bash
function configs() {
	code /home/manel/.config/hypr/
	code /home/manel/.config/waybar/config.jsonc
	code /home/manel/.config/waybar/style.css
	code /home/manel/.config/hypr/hyprpaper.conf
	code /home/manel/.config/anyrun/config.ron
	code /home/manel/escolinha/scripts/custom_commands.sh
	exit
}

function audio() {
	~/escolinha/scripts/pulseaudio.sh
	~/escolinha/scripts/pulseaudio.sh
	~/escolinha/scripts/pulseaudio.sh
	exit
}


function rfkillu () {
	rfkill unblock wlan
}

function rpcs3 () {
	rpcs3=ls ~/ps3/*.AppImage
	./rpcs3
	exit
}

function psx2 () {
	psx2=ls ~/ps2/*.AppImage
	./psx2
	exit
}

function intelij () {
	intelij=ls /home/manel/idea-IU-242.23339.11/bin/idea.sh
	./intelij
	exit
}

function fullscreenmode () {
	hyprctl keyword general:gaps_in 0
	hyprctl keyword general:gaps_out 0
	pkill waybar
}

function exitfullscreenmode () {
	hyprctl keyword general:gaps_in 5
	hyprctl keyword general:gaps_out 8
	exec waybar
}

function hyprland () {
	code /home/manel/.config/hypr/
	exit
}

function hyprland_fix () {
	cd /usr/lib
	sudo ln -s libhyprutils.so.* libhyprutils.so.2
	sudo chmod 777 libhyprutils.so.2
	exit
}

function discord_Update(){
	discord=(find /home/manel/Downloads/ -type f -name "discord-*")
	tar -xf $discord
	cp /home/manel/Downloads/Discord/ /opt/discord/
	echo "[Desktop Entry]
Name=Discord
StartupWMClass=discord
Comment=All-in-one voice and text chat for gamers that's free, secure, and works on both your desktop and phone.
GenericName=Internet Messenger
Exec=/opt/discord/Discord
Icon=discord
Type=Application
Categories=Network;InstantMessaging;
Path=/usr/bin" >> /opt/discord/discord.desktop

	rm /home/manel/Downloads/Discord

}

function Balatro(){
	wine /home/manel/Balatro.v1.0.0k/Balatro.exe
}

function vpn_start(){
	/usr/local/bin/vpn.sh start
}

function vpn_stop(){
	/usr/local/bin/vpn.sh stop
}


"$@"
