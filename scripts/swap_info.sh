#!/usr/bin/env bash

ICON=""

COLOR_LOW="\033[1;38;2;19;160;13m"
COLOR_MEDIUM="\033[1;38;2;255;255;85m"
COLOR_HIGH="\033[1;38;2;255;85;85m"
COLOR_TITLE="\033[1;38;2;170;130;255m"
COLOR_RESET="\033[0m"

if ! tail -n +2 /proc/swaps | grep -q '.'; then
    exit 1
fi

tail -n +2 /proc/swaps | while read -r filename type total_kb used_kb priority; do
    if [ "$total_kb" -eq 0 ]; then
        continue
    fi

    swap_total_gib=$(awk "BEGIN {printf \"%.1f\", $total_kb / 1048576}")
    swap_used_gib=$(awk "BEGIN {printf \"%.1f\", $used_kb / 1048576}")
    swap_percent=$(awk "BEGIN {printf \"%.0f\", $used_kb * 100 / $total_kb}")

    if ((swap_percent >= 80)); then
        color_percent="${COLOR_HIGH}${swap_percent}%${COLOR_RESET}"
    elif ((swap_percent >= 40)); then
        color_percent="${COLOR_MEDIUM}${swap_percent}%${COLOR_RESET}"
    else
        color_percent="${COLOR_LOW}${swap_percent}%${COLOR_RESET}"
    fi

    if [[ "$filename" == *zram* ]]; then
        title="zram"
    else
        title="Swap"
    fi

    title_formatted="${COLOR_TITLE}     $title  ${COLOR_RESET}:"
    echo -e "$title_formatted ${swap_used_gib} GiB / ${swap_total_gib} GiB (${color_percent})"
done
