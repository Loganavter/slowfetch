#!/usr/bin/env bash

ICON="󱚍"

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

process_timestamp() {
    local timestamp=$1
    if ! [[ "$timestamp" =~ ^[0-9]+$ ]]; then
        return 1
    fi

    local now
    now=$(date +%s)
    local diff=$((now - timestamp))

    if [ "$diff" -lt 0 ]; then
        return 1
    fi

    format_duration "$diff"
    return 0
}

COLOR_KEY="\033[1;32m"
COLOR_RESET="\033[0m"
KEY="${COLOR_KEY}     ${ICON} Last Update${COLOR_RESET}"

if command -v pacman &>/dev/null; then
    last_upgrade_str=$(grep -i 'full system upgrade' /var/log/pacman.log | tail -1 | awk -F'[][]' '{print $2}')
    if [ -n "$last_upgrade_str" ]; then
        timestamp=$(date -d "$(echo "$last_upgrade_str" | cut -d'T' -f1)" +%s 2>/dev/null)
        if result=$(process_timestamp "$timestamp"); then
            echo -e "${KEY} : ${result}"
            exit 0
        fi
    fi
fi

if command -v dpkg &>/dev/null; then
    last_upgrade_str=$(grep 'upgrade ' /var/log/dpkg.log | tail -1 | awk '{print $1 " " $2}')
    if [ -n "$last_upgrade_str" ]; then
        timestamp=$(date -d "$last_upgrade_str" +%s 2>/dev/null)
        if result=$(process_timestamp "$timestamp"); then
            echo -e "${KEY} : ${result}"
            exit 0
        fi
    fi
fi

if command -v dnf &>/dev/null; then
    timestamp=$(rpm -qa --qf '%{installtime}\n' | sort -n | tail -1)
    if result=$(process_timestamp "$timestamp"); then
        echo -e "${KEY} : ${result}"
        exit 0
    fi
fi

if command -v nix-env &>/dev/null; then
    date_str=$(nix-env --list-generations | grep '^ *[0-9]' | tail -n 1 | awk '{print $2}')
    if [ -n "$date_str" ]; then
        timestamp=$(date -d "$date_str" +%s 2>/dev/null)
        if result=$(process_timestamp "$timestamp"); then
            echo -e "${KEY} : ${result}"
            exit 0
        fi
    fi
fi

if command -v zypper &>/dev/null && [ -f /var/log/zypp/history ]; then
    timestamp=$(stat -c %Y /var/log/zypp/history)
    if result=$(process_timestamp "$timestamp"); then
        echo -e "${KEY} : ${result}"
        exit 0
    fi
fi

if command -v pkg &>/dev/null && [ -d /var/db/pkg ]; then
    timestamp=$(stat -c %Y /var/db/pkg)
    if result=$(process_timestamp "$timestamp"); then
        echo -e "${KEY} : ${result}"
        exit 0
    fi
fi

exit 1
