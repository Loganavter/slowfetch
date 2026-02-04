#!/usr/bin/env bash

ICON="󰒍"

if [[ "$LANG" =~ ^ru ]]; then
    ERROR_CURL_NOT_FOUND="curl не найден"
    ERROR_TEST_FAILED="Тест не удался"
else
    ERROR_CURL_NOT_FOUND="curl not found"
    ERROR_TEST_FAILED="Test failed"
fi

TEST_FILE_URL="https://speed.cloudflare.com/__down?bytes=10000000"
ROUND_TO=50

if ! command -v curl &>/dev/null; then
    echo "$ERROR_CURL_NOT_FOUND"
    exit 1
fi

>&2 echo "Fastfetch: Running a single CDN download test..."

speed_bytes_per_sec=$(curl -s -o /dev/null -w '%{speed_download}' "$TEST_FILE_URL")
speed_bytes_per_sec=${speed_bytes_per_sec%.*}

if ! [[ "$speed_bytes_per_sec" =~ ^[0-9]+$ ]] || [[ "$speed_bytes_per_sec" -eq 0 ]]; then
    echo "$ERROR_TEST_FAILED"
    exit 1
fi

speed_mbits_per_sec=$(awk "BEGIN {printf \"%.2f\", $speed_bytes_per_sec * 8 / 1000000}")

rounded_multiple=$(awk -v speed="$speed_mbits_per_sec" -v round_to="$ROUND_TO" 'BEGIN { printf "%.0f", speed / round_to }')
rounded_speed=$((rounded_multiple * ROUND_TO))

result_string="~${rounded_speed} Mbit/s"
COLOR_KEY="\033[1;32m"
COLOR_RESET="\033[0m"
KEY="${COLOR_KEY}  ${ICON} D Speed${COLOR_RESET}"

echo -e "${KEY} : ${result_string}"
