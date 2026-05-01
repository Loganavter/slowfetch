#!/usr/bin/env bash

ICON="🎵"
temp_art_path=""

cleanup() {
    if [ -n "$temp_art_path" ] && [ -f "$temp_art_path" ]; then
        rm -f "$temp_art_path"
    fi
}

decode_file_url_path() {
    local encoded_path=$1
    encoded_path=${encoded_path//+/ }
    printf '%b' "${encoded_path//%/\\x}"
}

trap cleanup EXIT

if ! command -v playerctl &>/dev/null || ! command -v chafa &>/dev/null; then
    exit 1
fi

art_url=$(playerctl metadata mpris:artUrl 2>/dev/null)

if [ -z "$art_url" ]; then
    exit 1
fi

case "$art_url" in
file://*)
    art_path=$(decode_file_url_path "${art_url#file://}")
    ;;
http://*|https://*)
    if ! command -v curl &>/dev/null; then
        exit 1
    fi
    temp_art_path=$(mktemp)
    if ! curl -fsSL "$art_url" -o "$temp_art_path"; then
        exit 1
    fi
    art_path="$temp_art_path"
    ;;
*)
    exit 1
    ;;
esac

if [ ! -f "$art_path" ]; then
    exit 1
fi

chafa -s 60x80 "$art_path" | awk '{print "  "$0}'
