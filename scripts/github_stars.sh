#!/usr/bin/env bash

ICON=""

if [[ "$LANG" =~ ^ru ]]; then
    ERROR_GH_JQ_REQUIRED="Ошибка: требуется gh или jq"
    ERROR_NOT_LOGGED_IN="Ошибка: не авторизован в gh"
    ERROR_NO_REPOS="Ошибка: не настроены GitHub репозитории"
    ERROR_MSG="Ошибка"
else
    ERROR_GH_JQ_REQUIRED="Error: gh or jq required"
    ERROR_NOT_LOGGED_IN="Error: Not logged in to gh"
    ERROR_NO_REPOS="Error: No GitHub repositories configured"
    ERROR_MSG="Error"
fi

CACHE_DIR="$HOME/.cache/fastfetch"
CACHE_FILE="$CACHE_DIR/github_stars.cache"
CACHE_DURATION_SECONDS=$((30 * 60))
SCRIPT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
REPO_FILE="${SCRIPT_DIR%/scripts}/github_stars.repos"

mkdir -p "$CACHE_DIR"

if [ -f "$CACHE_FILE" ]; then
    cached_timestamp=$(head -n 1 "$CACHE_FILE")
    cached_stars=$(tail -n 1 "$CACHE_FILE")
    current_time=$(date +%s)

    if [[ "$cached_timestamp" =~ ^[0-9]+$ ]] && [[ "$cached_stars" =~ ^[0-9]+$ ]]; then
        cache_age=$((current_time - cached_timestamp))

        if [ "$cache_age" -lt "$CACHE_DURATION_SECONDS" ]; then
            if [ "$cached_stars" -eq 0 ]; then
                exit 1
            fi
            COLOR_KEY="\033[1;32m"
            COLOR_RESET="\033[0m"
            KEY="${COLOR_KEY}     ${ICON} Github Stars${COLOR_RESET}"
            echo -e "${KEY} : ${cached_stars}"
            exit 0
        fi
    fi
fi

COLOR_KEY="\033[1;32m"
COLOR_RESET="\033[0m"
KEY="${COLOR_KEY}     ${ICON} Github Stars${COLOR_RESET}"

load_repos() {
    local repos=()

    if [ -f "$REPO_FILE" ]; then
        mapfile -t repos < <(sed '/^[[:space:]]*$/d' "$REPO_FILE")
    fi

    if [ ${#repos[@]} -gt 0 ]; then
        printf '%s\n' "${repos[@]}"
    fi
}

fetch_new_data() {
    local repos=()
    local total_stars=0
    local stars

    mapfile -t repos < <(load_repos)

    if [ ${#repos[@]} -eq 0 ]; then
        echo "$ERROR_NO_REPOS"
        return 1
    fi

    if ! command -v gh &>/dev/null || ! command -v jq &>/dev/null; then
        echo "$ERROR_GH_JQ_REQUIRED"
        return 1
    fi
    if ! gh auth status &>/dev/null; then
        echo "$ERROR_NOT_LOGGED_IN"
        return 1
    fi

    for repo in "${repos[@]}"; do
        stars=$(gh api "repos/$repo" --jq '.stargazers_count' 2>/dev/null || echo 0)
        if [[ "$stars" =~ ^[0-9]+$ ]]; then
            total_stars=$((total_stars + stars))
        fi
    done
    echo "$total_stars"
}

new_total_stars=$(fetch_new_data)

if [[ "$new_total_stars" =~ ^[0-9]+$ ]]; then
    if [ "$new_total_stars" -eq 0 ]; then
        exit 1
    fi
    printf "%s\n%s" "$(date +%s)" "$new_total_stars" >"$CACHE_FILE"
    echo -e "${KEY} : ${new_total_stars}"
else
    if [ -f "$CACHE_FILE" ] && [[ "$(tail -n 1 "$CACHE_FILE")" =~ ^[0-9]+$ ]]; then
        cached_stars=$(tail -n 1 "$CACHE_FILE")
        if [ "$cached_stars" -eq 0 ]; then
            exit 1
        fi
        echo -e "${KEY} : ${cached_stars}"
    else
        echo -e "${KEY} : ${new_total_stars:-$ERROR_MSG}"
    fi
fi
