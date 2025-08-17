#!/bin/bash

ICON=""

KEY_COLOR="\033[0;38;2;85;85;255m"
RESET_COLOR="\033[0m"
KEY_STRING="      Ori"

if ! command -v xrandr &>/dev/null; then
    exit 1
fi

xrandr --query | grep -w 'connected' | awk -v key_color="$KEY_COLOR" -v reset_color="$RESET_COLOR" -v key_string="$KEY_STRING" '
{
    orientation = "horizontal" 
    for (i = 3; i <= NF; i++) {
        if ($i ~ /^[0-9]+x[0-9]+\+[0-9]+\+[0-9]+$/) {
            next_field_index = i + 1
            if (next_field_index <= NF) {
                next_field_value = $(next_field_index)
                if (next_field_value == "left" || next_field_value == "right" || next_field_value == "inverted") {
                    orientation = "vertical"
                }
            }
            break
        }
    }
    
    display_info = "Display " (NR-1) " - " orientation

    print key_color key_string reset_color " : " display_info
}'
