#!/bin/bash

ICON="󰇧"

declare -A browsers=(
    [firefox]="Firefox"
    [chrome]="Google Chrome"
    [chromium]="Chromium"
    [opera]="Opera"
    [msedge]="Microsoft Edge"
    [brave]="Brave"
    [safari]="Safari"
    [tor]="Tor Browser"
    [vivaldi - bin]="Vivaldi"
    [yandex - browser]="Yandex Browser"
    [floorp]="Floorp"
    [waterfox]="Waterfox"
    [pale]="Pale Moon"
    [maxthon]="Maxthon"
)

IFS='|'
process_pattern="${!browsers[*]}"
IFS=$' \t\n' 

found_pid=$(pgrep -x "$process_pattern" | head -n 1)

if [ -n "$found_pid" ]; then
    process_name=$(ps -p "$found_pid" -o comm=)

    echo "${browsers[$process_name]:-$process_name}"
    exit 0
fi

if [ -n "$BROWSER" ]; then
    basename "$BROWSER" | sed 's/./\U&/1'
    exit 0
fi

echo "Not running"
exit 1
