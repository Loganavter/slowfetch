#!/usr/bin/env bash

ICON=""

COLOR_LOW="\033[1;38;2;19;160;13m"
COLOR_MEDIUM="\033[1;38;2;255;255;85m"
COLOR_HIGH="\033[1;38;2;255;85;85m"
COLOR_RESET="\033[0m"

used_mib=""
total_mib=""

if command -v nvidia-smi &>/dev/null; then
    mapfile -t smi_output < <(nvidia-smi --query-gpu=memory.used,memory.total --format=csv,noheader,nounits)
    if [ -n "${smi_output[0]}" ]; then
        read used_mib total_mib <<<"$(echo "${smi_output[0]}" | tr -d ' ' | tr ',' ' ')"
    fi
fi

if [ -z "$used_mib" ] && [ -d /sys/class/drm/ ]; then
    for card in /sys/class/drm/card*; do
        if [ -f "$card/device/vendor" ] && [ "$(cat "$card/device/vendor")" = "0x1002" ]; then
            if [ -f "$card/device/mem_info_vram_used" ] && [ -f "$card/device/mem_info_vram_total" ]; then
                used_bytes=$(cat "$card/device/mem_info_vram_used")
                total_bytes=$(cat "$card/device/mem_info_vram_total")

                used_mib=$(awk -v bytes="$used_bytes" 'BEGIN { print bytes / 1024 / 1024 }')
                total_mib=$(awk -v bytes="$total_bytes" 'BEGIN { print bytes / 1024 / 1024 }')

                break
            fi
        fi
    done
fi

if [ -z "$used_mib" ] || [ -z "$total_mib" ] || [ "$(echo "$total_mib" | cut -d'.' -f1)" -eq 0 ]; then
    exit 1
fi

used_gib=$(awk "BEGIN {printf \"%.1f\", $used_mib / 1024}")
total_gib=$(awk "BEGIN {printf \"%.1f\", $total_mib / 1024}")
memory_percent=$(awk "BEGIN {printf \"%.0f\", ($used_mib / $total_mib) * 100}")

if [[ $memory_percent -ge 80 ]]; then
    color="$COLOR_HIGH"
elif [[ $memory_percent -ge 50 ]]; then
    color="$COLOR_MEDIUM"
else
    color="$COLOR_LOW"
fi

COLOR_KEY="\033[1;38;2;70;110;180m"
KEY="${COLOR_KEY}    ${ICON} VRAM${COLOR_RESET}"
echo -e "${KEY} : ${used_gib} GiB / ${total_gib} GiB (${color}${memory_percent}%${COLOR_RESET})"
