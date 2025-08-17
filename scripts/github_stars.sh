#!/bin/bash

ICON=""

if [[ "$LANG" =~ ^ru ]]; then
    ERROR_GH_JQ_REQUIRED="Ошибка: требуется gh или jq"
    ERROR_NOT_LOGGED_IN="Ошибка: не авторизован в gh"
    ERROR_MSG="Ошибка"
else
    ERROR_GH_JQ_REQUIRED="Error: gh or jq required"
    ERROR_NOT_LOGGED_IN="Error: Not logged in to gh"
    ERROR_MSG="Error"
fi

CACHE_DIR="$HOME/.cache/fastfetch"
CACHE_FILE="$CACHE_DIR/github_stars.cache"
CACHE_DURATION_SECONDS=$((30 * 60))

mkdir -p "$CACHE_DIR"

if [ -f "$CACHE_FILE" ]; then
    cached_timestamp=$(head -n 1 "$CACHE_FILE")
    cached_stars=$(tail -n 1 "$CACHE_FILE")
    current_time=$(date +%s)

    if [[ "$cached_timestamp" =~ ^[0-9]+$ ]] && [[ "$cached_stars" =~ ^[0-9]+$ ]]; then
        cache_age=$((current_time - cached_timestamp))

        if [ "$cache_age" -lt "$CACHE_DURATION_SECONDS" ]; then
            echo "$cached_stars"
            exit 0
        fi
    fi
fi

fetch_new_data() {
    if ! command -v gh &>/dev/null || ! command -v jq &>/dev/null; then
        echo "$ERROR_GH_JQ_REQUIRED"
        exit 1
    fi
    if ! gh auth status &>/dev/null; then
        echo "$ERROR_NOT_LOGGED_IN"
        exit 1
    fi

    local REPOS=(
        "Loganavter/Improve-ImgSLI"
        "Loganavter/media_archive"
        "Loganavter/slowfetch"
        "Loganavter/Denoise-Compact"
        "Loganavter/VobSub-Index-File-Fast-Editor"
    )
    local total_stars=0

    for repo in "${REPOS[@]}"; do
        stars=$(gh api "repos/$repo" --jq '.stargazers_count' 2>/dev/null || echo 0)
        if [[ "$stars" =~ ^[0-9]+$ ]]; then
            total_stars=$((total_stars + stars))
        fi
    done
    echo "$total_stars"
}

new_total_stars=$(fetch_new_data)

if [[ "$new_total_stars" =~ ^[0-9]+$ ]]; then
    printf "%s\n%s" "$(date +%s)" "$new_total_stars" >"$CACHE_FILE"
    echo "$new_total_stars"
else
    if [ -f "$CACHE_FILE" ] && [[ "$(tail -n 1 "$CACHE_FILE")" =~ ^[0-9]+$ ]]; then
        tail -n 1 "$CACHE_FILE"
    else
        echo "$ERROR_MSG"
    fi
fi
