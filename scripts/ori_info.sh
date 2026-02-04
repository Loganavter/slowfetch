#!/usr/bin/env bash

ICON=""
KEY_COLOR="\033[1;38;2;85;85;255m"
RESET_COLOR="\033[0m"
KEY_STRING="     ${ICON} Ori"

get_wlr() {
    if ! command -v wlr-randr &>/dev/null; then return 1; fi

    if command -v jq &>/dev/null; then
        local wlr_json
        wlr_json=$(wlr-randr --json 2>/dev/null)
        if [[ -n "$wlr_json" && "$wlr_json" != "[]" ]]; then
            echo "$wlr_json" | jq -r '
                to_entries | .[] | select(.value.enabled) | 
                .key as $idx | .value.transform as $t |
                if ($t == "90" or $t == "270" or $t == "flipped-90" or $t == "flipped-270") 
                then "vertical" else "horizontal" end |
                "\($idx) - \(.)"' | while read -r line; do
                echo -e "${KEY_COLOR}${KEY_STRING}${RESET_COLOR} : Display ${line}"
            done
            return 0
        fi
    fi

    local res
    res=$(wlr-randr 2>/dev/null | awk -v kc="$KEY_COLOR" -v rc="$RESET_COLOR" -v ks="$KEY_STRING" '
        BEGIN { idx=0; proc=0; f=0 }
        /^[^ ]/ { if (proc && en) { print_r(); f=1 }; en=0; tr="normal"; proc=1 }
        /Enabled: yes/ { en=1 }
        /Transform:/ { tr=$2 }
        END { if (proc && en) { print_r(); f=1 }; if (!f) exit 1 }
        function print_r() {
            o = (tr=="90" || tr=="270" || tr ~ /flipped-90|270/) ? "vertical" : "horizontal"
            print kc ks rc " : Display " idx " - " o; idx++
        }')
    if [[ $? -eq 0 ]]; then
        echo -e "$res"
        return 0
    fi
    return 1
}

get_gnome_xml() {
    local xml_file="$HOME/.config/monitors.xml"
    if [[ ! -f "$xml_file" ]]; then return 1; fi

    awk -v kc="$KEY_COLOR" -v rc="$RESET_COLOR" -v ks="$KEY_STRING" '
    BEGIN { idx=0; conf=0; logi=0; found=0 }
    /<configuration>/ { if (conf == 0) conf = 1 }
    /<\/configuration>/ { if (conf == 1) exit }
    conf && /<logicalmonitor>/ { logi=1; rot="normal" }
    logi && /<rotation>/ { gsub(/.*<rotation>|<\/rotation>.*/, "", $0); rot=$0 }
    logi && /<\/logicalmonitor>/ {
        ori = (rot == "left" || rot == "right") ? "vertical" : "horizontal"
        print kc ks rc " : Display " idx " - " ori
        idx++; logi=0; found=1
    }
    END { if (found == 0) exit 1 }' "$xml_file"
}

get_xrandr() {
    if ! command -v xrandr &>/dev/null; then return 1; fi
    local x_data
    x_data=$(xrandr --query 2>/dev/null | grep -w 'connected')
    if [[ -z "$x_data" ]]; then return 1; fi

    echo "$x_data" | awk -v kc="$KEY_COLOR" -v rc="$RESET_COLOR" -v ks="$KEY_STRING" '
    {
        ori = "horizontal" 
        for (i = 3; i <= NF; i++) {
            if ($i ~ /^[0-9]+x[0-9]+\+[0-9]+\+[0-9]+$/) {
                if ((i+1) <= NF) {
                    v = $(i+1)
                    if (v == "left" || v == "right") ori = "vertical"
                }
                break
            }
        }
        print kc ks rc " : Display " (NR-1) " - " ori
    }'
}

if ! get_wlr; then
    if ! get_gnome_xml; then
        if ! get_xrandr; then
            exit 1
        fi
    fi
fi
