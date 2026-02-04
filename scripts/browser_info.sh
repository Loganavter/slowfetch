#!/usr/bin/env bash

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

COLOR_KEY="\033[1;32m"
COLOR_RESET="\033[0m"
KEY="${COLOR_KEY}  ${ICON} Browser${COLOR_RESET}"

found_pid=$(pgrep -x "$process_pattern" | head -n 1)

if [ -n "$found_pid" ]; then
    process_name=$(ps -p "$found_pid" -o comm=)

    echo -e "${KEY} : ${browsers[$process_name]:-$process_name}"
    exit 0
fi

if [ -n "$BROWSER" ]; then
    browser_name=$(basename "$BROWSER" | sed 's/./\U&/1')
    echo -e "${KEY} : ${browser_name}"
    exit 0
fi

echo -e "${KEY} : Not running"
exit 1
