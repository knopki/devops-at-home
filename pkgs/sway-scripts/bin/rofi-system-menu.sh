#!/usr/bin/env bash
set -euo pipefail
IFS=""

function killmenu() {
	local selection=$(ps -ef | sed 1d | rofi -i -dmenu -p "Kill")
	[[ -z "$selection" ]] && exit

	pid=$(awk '{print $2}' <<<"$selection" | tr '\n' ' ')
	[[ -z "$pid" ]] && exit

	notify-send "Killing Process:" "$selection"
	kill "$pid"
}

readonly OPTIONS=(
	"<u>Lock</u> screen"
	"<u>Reload</u> Sway config"
	"<u>Kill</u> process"
	"Manage <u>services</u>"
	"<u>Suspend</u> (RAM)"
	"<u>Hibernate</u> (HDD)"
	"<u>Hybrid Sleep</u> (RAM and HDD)"
	"<u>Suspend Then Hibernate</u>"
	"<u>Exit</u> Sway and logout"
	"<u>Reboot</u> machine"
	"<u>Shutdown</u> machine"
	"Reboot to <u>UEFI</u>"
)

readonly SELECTION=$(
	printf "%s\n" "${OPTIONS[@]}" |
		rofi -i -dmenu -markup-rows -p "System action" |
		grep -o "<u>.*</u>" | sed 's/\(<u>\|<\/u>\)//g' |
		tr '[:upper:]' '[:lower:]'
)

case "$SELECTION" in
'exit') swaymsg exit ;;
'lock') swaymsg exec loginctl lock-session ;;
'reboot') systemctl reboot -i ;;
'reload') swaymsg reload ;;
'shutdown') systemctl poweroff -i ;;
'suspend') systemctl suspend -i ;;
'hibernate') systemctl hibernate -i ;;
'hybrid sleep') systemctl hybrid-sleep -i ;;
'suspend then hibernate') systemctl suspend-then-hibernate -i ;;
'uefi') systemctl reboot -i --firmware-setup ;;
'services') rofi-systemd ;;
'kill') killmenu ;;
*) exit 0 ;;
esac
