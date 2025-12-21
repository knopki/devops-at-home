#!/usr/bin/env bash

# Default values
APP_NAME="cosmic-notify-send"
REPLACE_ID=0
ICON=""
EXPIRE_TIME=5000
URGENCY_BYTE=1 # normal (0=low, 1=normal, 2=critical)

# Arguments parsing
while [[ $# -gt 0 ]]; do
  case "$1" in
    -a|--app-name) APP_NAME="$2"; shift 2 ;;
    -r|--replace-id) REPLACE_ID="$2"; shift 2 ;;
    -i|--icon) ICON="$2"; shift 2 ;;
    -t|--expire-time) EXPIRE_TIME="$2"; shift 2 ;;
    -u|--urgency)
      case "$2" in
        low) URGENCY_BYTE=0 ;;
        normal) URGENCY_BYTE=1 ;;
        critical) URGENCY_BYTE=2 ;;
      esac
      shift 2 ;;
    -*) shift ;; # Skiping not supporting options
    *) break ;;  # Other - SUMMARY and BODY
  esac
done

SUMMARY="${1:-}"
BODY="${2:-}"

# Call D-Bus method
gdbus call --session \
    --dest org.freedesktop.Notifications \
    --object-path /org/freedesktop/Notifications \
    --method org.freedesktop.Notifications.Notify \
    "$APP_NAME" \
    "$REPLACE_ID" \
    "$ICON" \
    "$SUMMARY" \
    "$BODY" \
    '[]' \
    "{\"urgency\": <byte $URGENCY_BYTE>}" \
    "$EXPIRE_TIME"
