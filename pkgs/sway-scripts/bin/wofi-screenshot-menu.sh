#!/usr/bin/env bash
set -euo pipefail
IFS=""
: "${XDG_CACHE_HOME:=~/.cache}"
CACHE=$XDG_CACHE_HOME/wofi-screenshot-menu

if [ $# = 0 ]; then
	echo "Usage: $(basename $0) directory"
	exit 1
fi
readonly SCRNDIR="$*"

function shot() {
	local action="$1"
	mkdir -p "$SCRNDIR"
	local timestamp=$(date +%Y-%m-%d-%H-%M-%S)
	local filename="$SCRNDIR/scrn-$timestamp.png"
	grimshot --notify save $action "$filename" >/dev/null
	cat "$filename" | wl-copy --type image/png
}

function pick_color() {
	grim -g "$(slurp -p)" -t ppm - |
		convert - -format '%[pixel:p{0,0}]' txt:- |
		tail -n 1 | grep -o '[^ ]*$' | tr -d '\n' | wl-copy
}

readonly OPTIONS=(
	"Manually select an <u>area</u>"
	"Select <u>window</u> and capture screenshot"
	"Capture <u>active</u> window screenshot"
	"Capture currently active <u>output</u>"
	"Capture all visible <u>screen</u>s"
	"Pick a color under <u>cursor</u>"
)

readonly SELECTION=$(
	printf "%s\n" "${OPTIONS[@]}" |
		wofi -k $CACHE -i -d -m -p "Screenshot" |
		grep -o "<u>.*</u>" | sed 's/\(<u>\|<\/u>\)//g' |
		tr '[:upper:]' '[:lower:]'
)

case "$SELECTION" in
"cursor") pick_color ;;
"") exit 0 ;;
*) shot "$SELECTION" ;;
esac
