#!/bin/bash

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

birth_install=$(stat -c %W /)
if ! [[ "$birth_install" =~ ^[0-9]+$ ]]; then
    exit 1
fi

current=$(date +%s)
time_progression=$((current - birth_install))

format_duration "$time_progression"
