#!/usr/bin/env bash
IFS="
"

: {PASSWORD_STORE_DIR:-~/.password-store}

# choose file
readonly name=$(
	find -L "$PASSWORD_STORE_DIR" -iname '*.gpg' -printf '%P\n' |
		sed 's/\.gpg$//' |
		rofi -p "pass" -no-auto-select -dmenu -i "$@"
)
[ -n "${name:-}" ] || exit

# read content
readonly content=$(pass show "$name")
[ -n "${content:-}" ] || exit 1

# generate menu
choices="<b>password</b>\n"
readonly fields=$(echo -en "$content" | grep -e "^.*:.*$" | sed -e 's/:.*$//')

for field in $fields; do
	if [ "$field" = "otpauth" ]; then choices+="<b>OTP</b>\n"; fi
done
choices+="<b>multiline</b>\n"
for field in $fields; do
	if [ "$field" != "otpauth" ]; then choices+="${field}\n"; fi
done

readonly choice=$(echo -en "$choices" | rofi -i -dmenu -markup-rows -p "what to copy")

# do
case "$choice" in
"<b>password</b>")
	echo -en "$content" |
		head -n 1 |
		awk 'BEGIN{ORS=""} {print; exit}' |
		wl-copy
	;;
"<b>multiline</b>")
	echo -en "$content" | wl-copy
	;;
"<b>OTP</b>")
	pass otp "$name" |
		awk 'BEGIN{ORS=""} {print; exit}' |
		wl-copy
	;;
*)
	value=$(echo -en "$content" |
		awk -v key="$choice" 'match($0, key) {print $0; exit}' |
		sed -n "s/${choice}:\s\?\(.*\)/\1/p")
	if [ "$choice" = "url" ]; then
		xdg-open "$value"
	else
		echo -en "$value" | wl-copy
	fi
	;;
esac
