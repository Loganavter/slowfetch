#!/bin/bash

ICON="󰋊"

COLOR_DISK_ICON="\033[0;38;2;243;84;241m"
COLOR_LOW="\033[0;38;2;19;160;13m"
COLOR_MEDIUM="\033[0;38;2;255;255;85m"
COLOR_HIGH="\033[0;38;2;255;85;85m"
COLOR_RESET="\033[0m"

convert_size() {
    local size=$1
    if ! [[ "$size" =~ ^[0-9]+$ ]]; then
        echo "N/A"
        return 1
    fi

    if ((size >= 1099511627776)); then
        awk -v s="$size" 'BEGIN {printf "%.2f TiB", s/1099511627776}'
    elif ((size >= 1073741824)); then
        awk -v s="$size" 'BEGIN {printf "%.2f GiB", s/1073741824}'
    elif ((size >= 1048576)); then
        awk -v s="$size" 'BEGIN {printf "%.2f MiB", s/1048576}'
    elif ((size >= 1024)); then
        awk -v s="$size" 'BEGIN {printf "%.2f KiB", s/1024}'
    else echo "$size B"; fi
}

extract_vendor() {
    local model="$1"
    local known_vendors=(
        "Samsung" "Seagate" "WDC" "Western Digital" "WD" "HGST" "Hitachi" "Toshiba" "SanDisk"
        "Kingston" "Intel" "Crucial" "Micron" "SK hynix" "KIOXIA" "ADATA" "Apacer"
        "Corsair" "Lexar" "PNY" "Patriot" "Transcend" "Verbatim"
    )

    for v in "${known_vendors[@]}"; do
        if [[ "${model,,}" == "${v,,}"* ]]; then
            case "${v,,}" in
            "wdc" | "wd") vendor="Western Digital" ;;
            *) vendor="$v" ;;
            esac
            echo "$vendor"
            return
        fi
    done
    case "$model" in
    ST*)
        echo "Seagate"
        return
        ;;
    WD*)
        echo "Western Digital"
        return
        ;;
    MZ* | MZVL*)
        echo "Samsung"
        return
        ;;
    esac
}

declare -a disk_data

mapfile -t disk_paths < <(lsblk -dpno NAME,TYPE | awk '$2=="disk"{print $1}' | grep -E '^/dev/(sd|nvme|hd|vd)')

if [ ${#disk_paths[@]} -eq 0 ]; then
    echo "Диски не найдены."
    exit 1
fi

for disk_path in "${disk_paths[@]}"; do
    eval "$(lsblk -dpno TYPE,TRAN,ROTA,SIZE,VENDOR,MODEL -b "$disk_path" --pairs 2>/dev/null | head -n 1)"

    total_size_bytes=${SIZE:-0}

    transport_lower="${TRAN,,}"
    if [ "$transport_lower" = "usb" ]; then
        disk_type="USB"
    elif [ "$ROTA" = "1" ]; then
        disk_type="HDD"
    elif [[ "$disk_path" == /dev/nvme* ]] || [ "$transport_lower" == "nvme" ]; then
        disk_type="NVMe"
    else disk_type="SSD"; fi

    smartctl_output=$(smartctl -i "$disk_path" 2>/dev/null)
    model_info=$(echo "$smartctl_output" | grep -Ei "^(Device Model|Model Number):" | sed -e 's/^.*: *//' | head -n 1)

    final_vendor=$(extract_vendor "$model_info")
    [ -z "$final_vendor" ] && final_vendor=$(extract_vendor "${VENDOR//\\\"/}")
    [ -z "$final_vendor" ] && final_vendor=$(extract_vendor "${MODEL//\\\"/}")
    [ -z "$final_vendor" ] && final_vendor="$disk_type Drive"

    vendor_with_type="$final_vendor($disk_type)"
    total_size_hr=$(convert_size "$total_size_bytes")

    mapfile -t partitions < <(lsblk -lnpo NAME "$disk_path")
    winner_info=""
    max_size=0

    for part_path in "${partitions[@]}"; do
        mount_info=$(findmnt -n -u -o TARGET,FSTYPE "$part_path" 2>/dev/null | head -n 1)
        if [ -n "$mount_info" ]; then
            part_size=$(lsblk -dno SIZE -b "$part_path" 2>/dev/null)
            if ((part_size > max_size)); then
                max_size=$part_size
                winner_info="$mount_info"
            fi
        fi
    done

    if [ -n "$winner_info" ]; then
        IFS=' ' read -r mount_point file_system <<<"$winner_info"
        df_info=$(df -P -B1 "$mount_point" 2>/dev/null | tail -n 1)

        used_bytes=$(echo "$df_info" | awk '{print $3}')
        usage_percent=$(echo "$df_info" | awk '{print $5}' | tr -d '%')

        used_size_hr=$(convert_size "$used_bytes")
        disk_data+=("mounted|$vendor_with_type|$used_size_hr|$total_size_hr|$usage_percent|$file_system")
    else
        fs_type=$(lsblk -ls -no FSTYPE "$disk_path" | grep -v '^$' | head -n 1)
        disk_data+=("unmounted|$vendor_with_type|$total_size_hr|${fs_type:-no fs}")
    fi
done

max_len=0
for entry in "${disk_data[@]}"; do
    IFS='|' read -r _ vendor _ <<<"$entry"
    len=${#vendor}
    ((len > max_len)) && max_len=$len
done

first_line=true
for entry in "${disk_data[@]}"; do
    IFS='|' read -r status vendor part1 part2 part3 part4 <<<"$entry"
    printf -v formatted_vendor "%-${max_len}s" "$vendor"

    line=""
    if [[ "$status" == "mounted" ]]; then
        used_size="$part1"
        total_size="$part2"
        usage_percent="$part3"
        file_system="$part4"
        percent_int=$(printf "%.0f" "$usage_percent" 2>/dev/null)

        if ((percent_int >= 85)); then
            color_perc="${COLOR_HIGH}${usage_percent}%${COLOR_RESET}"
        elif ((percent_int >= 40)); then
            color_perc="${COLOR_MEDIUM}${usage_percent}%${COLOR_RESET}"
        else color_perc="${COLOR_LOW}${usage_percent}%${COLOR_RESET}"; fi

        line="- ${used_size} / ${total_size} (${color_perc}) - ${file_system}"
    else
        line="- unmounted / ${part1} - ${part2}"
    fi

    if $first_line; then
        echo -e "${formatted_vendor} ${line}"
        first_line=false
    else
        echo -e "${COLOR_DISK_ICON}  󰋊 Disk${COLOR_RESET} : ${formatted_vendor} ${line}"
    fi
done
