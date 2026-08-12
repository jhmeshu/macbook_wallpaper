#!/bin/bash
set -u

CONFIG_URL="https://raw.githubusercontent.com/jhmeshu/macbook_wallpaper/refs/heads/main/config.json"
LOCAL_DIR="/Users/Shared/company_wallpaper"
CONFIG_FILE="$LOCAL_DIR/config_remote.json"
IMAGE_FILE="$LOCAL_DIR/wallpaper.jpg"
VERSION_FILE="$LOCAL_DIR/version.txt"
TEMP_IMAGE="$LOCAL_DIR/wallpaper.tmp"

mkdir -p "$LOCAL_DIR"

# Download configuration
if ! /usr/bin/curl -fsSL --connect-timeout 15 --max-time 60 "$CONFIG_URL" -o "$CONFIG_FILE"; then
    exit 1
fi

# Simple JSON parsing for the expected config format.
REMOTE_VERSION=$(/usr/bin/grep -o '"version"[[:space:]]*:[[:space:]]*[0-9]\+' "$CONFIG_FILE" | /usr/bin/head -1 | /usr/bin/grep -o '[0-9]\+' | /usr/bin/head -1)
REMOTE_IMAGE=$(/usr/bin/grep -o '"url"[[:space:]]*:[[:space:]]*"[^"]*"' "$CONFIG_FILE" | /usr/bin/head -1 | /usr/bin/sed 's/.*"url"[[:space:]]*:[[:space:]]*"//; s/"$//')

if [ -z "${REMOTE_VERSION:-}" ] || [ -z "${REMOTE_IMAGE:-}" ]; then
    exit 1
fi

LOCAL_VERSION=0
if [ -f "$VERSION_FILE" ]; then
    LOCAL_VERSION=$(/bin/cat "$VERSION_FILE" 2>/dev/null || echo 0)
fi

if ! [[ "$REMOTE_VERSION" =~ ^[0-9]+$ ]] || ! [[ "$LOCAL_VERSION" =~ ^[0-9]+$ ]]; then
    exit 1
fi

# Only download when the cloud version is newer.
if [ "$REMOTE_VERSION" -gt "$LOCAL_VERSION" ]; then

    if ! /usr/bin/curl -fL --connect-timeout 15 --max-time 120 "$REMOTE_IMAGE" -o "$TEMP_IMAGE"; then
        /bin/rm -f "$TEMP_IMAGE"
        exit 1
    fi

    # Basic file sanity check.
    if [ ! -s "$TEMP_IMAGE" ]; then
        /bin/rm -f "$TEMP_IMAGE"
        exit 1
    fi

    /bin/mv -f "$TEMP_IMAGE" "$IMAGE_FILE"

    # Set wallpaper for the currently logged-in graphical user.
    CONSOLE_USER=$(/usr/bin/stat -f "%Su" /dev/console)

    if [ -n "$CONSOLE_USER" ] && [ "$CONSOLE_USER" != "root" ] && [ "$CONSOLE_USER" != "loginwindow" ]; then
        /usr/bin/sudo -u "$CONSOLE_USER" /usr/bin/osascript \
            -e "tell application \"System Events\" to set picture of every desktop to POSIX file \"$IMAGE_FILE\""
    fi

    /bin/echo "$REMOTE_VERSION" > "$VERSION_FILE"
fi

exit 0
