#!/bin/bash

ICON=""

COLOR_LOW="\033[0;38;2;19;160;13m"
COLOR_MEDIUM="\033[0;38;2;255;255;85m"
COLOR_HIGH="\033[0;38;2;255;85;85m"
COLOR_TITLE="\033[0;38;2;170;130;255m"
COLOR_RESET="\033[0m"

swap_total_kb=$(grep "SwapTotal" /proc/meminfo | awk '{print $2}')
swap_free_kb=$(grep "SwapFree" /proc/meminfo | awk '{print $2}')

if [ -z "$swap_total_kb" ] || [ "$swap_total_kb" -eq 0 ]; then exit 1; fi

swap_used_kb=$((swap_total_kb - swap_free_kb))
swap_total_gib=$(awk "BEGIN {printf \"%.1f\", $swap_total_kb / 1048576}")
swap_used_gib=$(awk "BEGIN {printf \"%.1f\", $swap_used_kb / 1048576}")
swap_percent=$(awk "BEGIN {printf \"%.0f\", $swap_used_kb * 100 / $swap_total_kb}")

if ((swap_percent >= 80)); then
    color_percent="${COLOR_HIGH}${swap_percent}%${COLOR_RESET}"
elif ((swap_percent >= 40)); then
    color_percent="${COLOR_MEDIUM}${swap_percent}%${COLOR_RESET}"
else color_percent="${COLOR_LOW}${swap_percent}%${COLOR_RESET}"; fi

title="Swap"
if lsmod | grep -wq "zram"; then title="zram"; fi

title_formatted="${COLOR_TITLE}     $title  ${COLOR_RESET}:"
echo -e "$title_formatted ${swap_used_gib} GiB / ${swap_total_gib} GiB (${color_percent})"
