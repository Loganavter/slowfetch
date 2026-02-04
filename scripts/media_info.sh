#!/usr/bin/env bash

ICON=""

COLOR_KEY="\033[1;32m"
COLOR_RESET="\033[0m"
KEY="${COLOR_KEY}  ${ICON} Play${COLOR_RESET}"

if ! command -v playerctl &>/dev/null; then
    echo -e "${KEY} : No media"
    exit 1
fi

media_info=$(playerctl metadata --format '{{artist}} - {{title}} ({{status}})' 2>/dev/null || echo 'No media')
echo -e "${KEY} : ${media_info}"
