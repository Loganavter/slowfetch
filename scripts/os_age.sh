#!/usr/bin/env bash

ICON="󱦟"

format_duration() {
    local total_seconds=$1

    if ! [[ "$total_seconds" =~ ^[0-9]+$ ]] || [ "$total_seconds" -lt 0 ]; then
        exit 1
    fi

    if [ "$total_seconds" -ge 86400 ]; then
        local days=$((total_seconds / 86400))
        local unit="days"
        [ "$days" -eq 1 ] && unit="day"
        echo "$days $unit"
    elif [ "$total_seconds" -ge 3600 ]; then
        local hours=$((total_seconds / 3600))
        local unit="hours"
        [ "$hours" -eq 1 ] && unit="hour"
        echo "$hours $unit"
    elif [ "$total_seconds" -ge 60 ]; then
        local mins=$((total_seconds / 60))
        local unit="mins"
        [ "$mins" -eq 1 ] && unit="min"
        echo "$mins $unit"
    else
        local secs=$total_seconds
        local unit="secs"
        [ "$secs" -eq 1 ] && unit="sec"
        echo "$secs $unit"
    fi
}

if [ ! -d / ]; then
    exit 1
fi

COLOR_KEY="\033[1;31m"
COLOR_RESET="\033[0m"
KEY="${COLOR_KEY}  ${ICON} OS Age ${COLOR_RESET}"

birth_install=$(stat -c %W / 2>/dev/null)

if [[ "$birth_install" == "-" ]] || [[ "$birth_install" == "0" ]]; then
    birth_install=0
fi

if [ "$birth_install" -eq 0 ]; then
    if command -v rpm >/dev/null; then
        birth_install=$(rpm -q --qf "%{INSTALLTIME}\n" filesystem 2>/dev/null)
    fi
    
    if [ -z "$birth_install" ] || [ "$birth_install" -eq 0 ]; then
        if [ -d /lost+found ]; then
            birth_install=$(stat -c %Y /lost+found 2>/dev/null)
        fi
    fi
    
    if [ -z "$birth_install" ] || [ "$birth_install" -eq 0 ]; then
        birth_install=$(stat -c %Y /etc/fstab 2>/dev/null)
    fi
fi

if ! [[ "$birth_install" =~ ^[0-9]+$ ]]; then
    exit 1
fi

current=$(date +%s)
time_progression=$((current - birth_install))

result=$(format_duration "$time_progression")
echo -e "${KEY}: ${result}"
