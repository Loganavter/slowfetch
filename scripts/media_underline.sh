#!/usr/bin/env bash

ICON="-"

play_info=$(playerctl metadata --format '{{artist}} - {{title}} ({{status}})' 2>/dev/null)

key_string="   Play : "

if [ -z "$play_info" ]; then
    full_display_string="${key_string}No media"
else
    play_info_trimmed=$(echo "$play_info" | sed 's/^[[:space:]]*//;s/[[:space:]]*$//')
    full_display_string="${key_string}${play_info_trimmed}"
fi

char_count=$(printf "%s" "$full_display_string" | wc -m)
((char_count--))

min_len=42
if ((char_count < min_len)); then
    char_count=$min_len
fi

line=$(printf '─%.0s' $(seq 1 $char_count))
echo "└${line}┘"
