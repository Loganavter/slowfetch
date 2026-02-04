#!/usr/bin/env bash

if ! command -v inxi &>/dev/null; then
    echo "Ошибка: inxi не установлен."
    exit 1
fi

ICON=""
COLOR_TITLE="\033[1;38;2;170;130;255m"
COLOR_RESET="\033[0m"

declare -A size_count_map
type_found=""
min_freq=0

while read -r line; do
    [[ "$line" =~ Device-[0-9]+ ]] || continue
    [[ "$line" =~ "no module installed" ]] && continue

    if [[ "$line" =~ type:[[:space:]]*([^[:space:]]+) ]]; then
        t="${BASH_REMATCH[1]}"
        [[ "$t" != "N/A" && -z "$type_found" ]] && type_found="$t"
    fi

    if [[ "$line" =~ size:[[:space:]]*([0-9.]+)[[:space:]]*(GiB|GB|MiB|MB) ]]; then
        val="${BASH_REMATCH[1]}"
        unit="${BASH_REMATCH[2]}"

        if [[ "$unit" =~ M ]]; then
            val=$(awk -v v="$val" 'BEGIN {printf "%.0f", v/1024}')
        else
            val=$(awk -v v="$val" 'BEGIN {printf "%.0f", v}')
        fi

        if [[ "$val" -gt 0 ]]; then
            size_count_map[$val]=$((size_count_map[$val] + 1))
        fi
    fi

    current_freq=0
    if [[ "$line" =~ (actual|configured):[[:space:]]*([0-9]+) ]]; then
        current_freq="${BASH_REMATCH[2]}"
    elif [[ "$line" =~ speed:[[:space:]]*(spec:[[:space:]]*)?([0-9]+) ]]; then
        current_freq="${BASH_REMATCH[2]}"
    fi

    if [[ "$current_freq" -gt 0 ]]; then
        if [[ "$min_freq" -eq 0 ]] || [[ "$current_freq" -lt "$min_freq" ]]; then
            min_freq="$current_freq"
        fi
    fi
done < <(inxi -m -y 1000 2>/dev/null)

formatted_size=""
if [ ${#size_count_map[@]} -gt 0 ]; then
    IFS=$'\n' sorted_keys=($(sort -rn <<<"${!size_count_map[*]}"))
    unset IFS
    for s in "${sorted_keys[@]}"; do
        formatted_size+="${s}x${size_count_map[$s]} "
    done
fi

type_out=${type_found:-"RAM"}
size_out=${formatted_size:-"N/A "}
freq_ghz="0.00 GHz"

if [[ "$min_freq" -gt 0 ]]; then
    freq_ghz=$(awk -v s="$min_freq" 'BEGIN {printf "%.2f GHz", s/1000}')
fi

echo -e "${COLOR_TITLE}    ${ICON} Specs ${COLOR_RESET}: ${type_out} ${size_out}GiB ${freq_ghz}"
