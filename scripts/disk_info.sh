#!/usr/bin/env bash

if ! command -v inxi &>/dev/null; then
    echo "Ошибка: inxi не установлен."
    exit 1
fi

ICON="󰋊"
COLOR_DISK_ICON="\033[1;38;2;243;84;241m"
COLOR_LOW="\033[1;38;2;19;160;13m"
COLOR_MEDIUM="\033[1;38;2;255;255;85m"
COLOR_HIGH="\033[1;38;2;255;85;85m"
COLOR_RESET="\033[0m"

convert_size() {
    local size=$1
    if ! [[ "$size" =~ ^[0-9]+$ ]]; then
        echo "N/A"
        return 1
    fi
    awk -v s="$size" 'BEGIN {
        if (s >= 1099511627776) printf "%.2f TiB", s/1099511627776
        else if (s >= 1073741824) printf "%.2f GiB", s/1073741824
        else if (s >= 1048576) printf "%.2f MiB", s/1048576
        else if (s >= 1024) printf "%.2f KiB", s/1024
        else printf "%d B", s
    }'
}

declare -A inxi_data
while read -r line; do
    if [[ "$line" =~ ID-[0-9]+:[[:space:]]*(/[^[:space:]]+)[[:space:]]*vendor:[[:space:]]*(.+)[[:space:]]*model:[[:space:]]*(.+) ]]; then
        dev_path="${BASH_REMATCH[1]}"
        vendor="${BASH_REMATCH[2]}"
        model="${BASH_REMATCH[3]}"
        model="${model%% size:*}"
        inxi_data["$dev_path"]="$(echo "$vendor $model" | xargs)"
    fi
done < <(inxi -d -c 0 -y 1000 2>/dev/null)

declare -a disk_data

mapfile -t disk_paths < <(lsblk -dpno NAME,TYPE | awk '$2=="disk"{print $1}' | grep -E '^/dev/(sd|nvme|hd|vd|mmcblk|xvd)')

if [ ${#disk_paths[@]} -eq 0 ]; then
    echo "Диски не найдены."
    exit 1
fi

for disk_path in "${disk_paths[@]}"; do
    unset TRAN ROTA SIZE VENDOR MODEL
    source <(lsblk -dpno TRAN,ROTA,SIZE,VENDOR,MODEL -b "$disk_path" --pairs 2>/dev/null)

    total_size_bytes=${SIZE:-0}
    transport_lower="${TRAN,,}"

    if [[ "$transport_lower" == "usb" ]]; then
        disk_type="USB"
    elif [[ "$disk_path" == *"/dev/nvme"* ]] || [[ "$transport_lower" == "nvme" ]]; then
        disk_type="NVMe"
    elif [[ "$ROTA" == "1" ]]; then
        disk_type="HDD"
    else
        disk_type="SSD"
    fi

    final_name="${inxi_data[$disk_path]}"
    if [ -z "$final_name" ]; then
        final_name="$(echo "${VENDOR} ${MODEL}" | xargs)"
    fi
    [ -z "$final_name" ] && final_name="${disk_type} Drive"

    vendor_with_type="${final_name} (${disk_type})"
    total_size_hr=$(convert_size "$total_size_bytes")

    winner_mount=""
    winner_fs=""
    max_part_size=0

    while read -r part_path; do
        mount_info=$(findmnt -n -u -o TARGET,FSTYPE "$part_path" 2>/dev/null | head -n 1)

        if [ -n "$mount_info" ]; then
            part_size=$(lsblk -dno SIZE -b "$part_path" 2>/dev/null)
            if [[ "$part_size" -gt "$max_part_size" ]]; then
                max_part_size=$part_size
                read -r winner_mount winner_fs <<<"$mount_info"
            fi
        fi
    done < <(lsblk -lnpo NAME "$disk_path")

    if [ -n "$winner_mount" ]; then
        df_info=$(df -P -B1 "$winner_mount" 2>/dev/null | tail -n 1)
        used_bytes=$(echo "$df_info" | awk '{print $3}')
        usage_percent=$(echo "$df_info" | awk '{print $5}' | tr -d '%')
        used_size_hr=$(convert_size "$used_bytes")

        disk_data+=("mounted|$vendor_with_type|$used_size_hr|$total_size_hr|$usage_percent|$winner_fs")
    else
        fs_type=$(lsblk -lnpo FSTYPE "$disk_path" | grep -vE "^$|^[[:space:]]*$" | head -n 1)
        disk_data+=("unmounted|$vendor_with_type|$total_size_hr|${fs_type:-no fs}")
    fi
done

max_len=0
for entry in "${disk_data[@]}"; do
    IFS='|' read -r status vendor rest <<<"$entry"
    len=${#vendor}
    ((len > max_len)) && max_len=$len
done

for entry in "${disk_data[@]}"; do
    IFS='|' read -r status vendor p1 p2 p3 p4 <<<"$entry"
    printf -v formatted_vendor "%-${max_len}s" "$vendor"

    if [[ "$status" == "mounted" ]]; then
        used_size="$p1"
        total_size="$p2"
        usage_percent="$p3"
        file_system="$p4"

        percent_int=${usage_percent%.*}

        if ((percent_int >= 85)); then
            color_perc="${COLOR_HIGH}${usage_percent}%${COLOR_RESET}"
        elif ((percent_int >= 40)); then
            color_perc="${COLOR_MEDIUM}${usage_percent}%${COLOR_RESET}"
        else
            color_perc="${COLOR_LOW}${usage_percent}%${COLOR_RESET}"
        fi

        line="- ${used_size} / ${total_size} (${color_perc}) - ${file_system}"
    else
        line="- unmounted / ${p1} - ${p2}"
    fi

    echo -e "  ${COLOR_DISK_ICON}${ICON} Disk${COLOR_RESET} : ${formatted_vendor} ${line}"
done
