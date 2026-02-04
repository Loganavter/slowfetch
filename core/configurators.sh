#!/usr/bin/env bash

custom_checklist() {
    local prompt="$1"
    local result_file="$2"
    shift 2
    local options=("$@")
    local count=${#options[@]}
    local cur=0
    local sel=()
    for ((i = 0; i < count; i++)); do sel[i]=0; done

    tput civis
    stty -echo
    printf '\e[?1000h\e[1006h'

    local need_redraw=true

    while true; do
        if $need_redraw; then
            local win_height=$(tput lines)
            local header_height=5
            local list_height=$((win_height - header_height))

            local start_idx=0
            if ((count > list_height)); then
                if ((cur > list_height / 2)); then start_idx=$((cur - list_height / 2)); fi
                if ((start_idx + list_height > count)); then start_idx=$((count - list_height)); fi
                ((start_idx < 0)) && start_idx=0
            fi

            tput home

            echo -e "${L_TUI_GH_REPOS_TITLE}\033[K"
            echo -e "  ────────────────────────────────────────────────────────────\033[K"
            echo -e "    ${L_TUI_GH_REPOS_HINT}\033[K"
            echo -e "  ────────────────────────────────────────────────────────────\033[K"
            echo -e "  ${FG_BLUE}${prompt}${RESET}\033[K"

            for ((i = start_idx; i < start_idx + list_height && i < count; i++)); do
                local display_idx=$((i + 1))

                if [ $i -eq $cur ]; then
                    local colored_box="[ ]"
                    [ ${sel[i]} -eq 1 ] && colored_box="${FG_GREEN}[x]${RESET}"
                    echo -e "  ${FG_BLUE}${BOLD}➜${RESET} ${colored_box} ${FG_WHITE}${BOLD}${options[i]}${RESET}\033[K"
                else
                    local colored_box="[ ]"
                    [ ${sel[i]} -eq 1 ] && colored_box="${FG_GREEN}[x]${RESET}"
                    echo -e "     ${colored_box} ${options[i]}\033[K"
                fi
            done
            tput ed
            need_redraw=false
        fi

        IFS= read -rsn1 key
        if [[ "$key" == $'\x1b' ]]; then
            read -rsn2 -t 0.001 rest
            if [[ "$rest" == "" ]]; then
                printf '\e[?1000l\e[1006l'
                stty echo
                tput cnorm
                return 1
            fi

            case "$rest" in
            '[A')
                if ((cur > 0)); then
                    ((cur--))
                    need_redraw=true
                fi
                ;;
            '[B')
                if ((cur < count - 1)); then
                    ((cur++))
                    need_redraw=true
                fi
                ;;
            esac

            if [[ "$rest" == "[<" ]]; then
                read -d 'M' mouse_data
                [[ "$mouse_data" == "64;"* && $cur -gt 0 ]] && ((cur--)) && need_redraw=true
                [[ "$mouse_data" == "65;"* && $cur -lt $((count - 1)) ]] && ((cur++)) && need_redraw=true
            fi
        else
            case "$key" in
            " ")
                [ ${sel[cur]} -eq 1 ] && sel[cur]=0 || sel[cur]=1
                need_redraw=true
                ;;
            "")
                break
                ;;
            "q" | "Q")
                printf '\e[?1000l\e[1006l'
                stty echo
                tput cnorm
                return 1
                ;;
            esac
        fi
    done

    printf '\e[?1000l\e[1006l'
    stty echo
    tput cnorm

    >"$result_file"
    for ((i = 0; i < count; i++)); do
        [ ${sel[i]} -eq 1 ] && echo "${options[i]}" >>"$result_file"
    done
    return 0
}

configure_module() {
    echo -e "${BOLD}${L_INFO_CONFIGURE_MODULES_HEADER}${RESET}"
    echo -e "1. ${L_INFO_CONFIGURE_GH_STARS}"
    echo -e "2. ${L_INFO_CONFIGURE_NEWS_SOURCE}"
    echo -e "3. ${L_INFO_CONFIGURE_CURRENCY_RATE}"
    echo "--------------------------"
    tput cnorm
    read -rp "$(echo -e "${BOLD}${L_PROMPT_CONFIGURE_MODULE}${RESET} ")" choice
    case $choice in
    1) configure_github_stars ;;
    2) configure_news_module ;;
    3) configure_currency_module ;;
    *) echo -e "${FG_RED}${L_ERROR_INVALID_CHOICE}${RESET}" ;;
    esac
}

configure_github_stars() {
    eval "$(get_paths)"
    local script_path="${SCRIPTS_PATH}/github_stars.sh"
    local tmp_sel=$(mktemp)

    while true; do
        clear
        echo -e "${BOLD}${L_INFO_CONFIGURE_GH_STARS_HEADER}${RESET}"
        echo "1. ${L_INFO_CONFIGURE_GH_FROM_REPOS}"
        echo "2. ${L_INFO_CONFIGURE_GH_MANUAL}"
        echo "--------------------------"
        echo "0. ${L_INFO_BACK}"
        tput cnorm
        read -rp "${L_PROMPT_CHOICE}: " gh_mode

        case $gh_mode in
        1)
            echo "${L_INFO_FETCHING_REPOS}"
            local repos=()
            mapfile -t repos < <(gh repo list --limit 100 --json "nameWithOwner" -q '.[].nameWithOwner' 2>/dev/null)
            if [ ${#repos[@]} -eq 0 ]; then
                echo "${L_ERROR_GH_REPOS_EMPTY}"
                sleep 1
                continue
            fi
            custom_checklist "${L_PROMPT_GH_SELECT_REPOS}" "$tmp_sel" "${repos[@]}"
            break
            ;;
        2)
            clear
            echo -e "${BOLD}${L_PROMPT_GH_MANUAL_INPUT}${RESET}"
            echo "${L_HINT_GH_MANUAL_EXAMPLE}"
            echo ""
            tput cnorm
            read -rp "${L_PROMPT_GH_ID}: " manual_input
            for item in $manual_input; do
                if [[ "$item" == */* ]]; then
                    echo "$item" >>"$tmp_sel"
                else
                    echo -e "${FG_RED}${L_ERROR_GH_SKIP_ITEM}${RESET}"
                fi
            done
            break
            ;;
        0)
            rm -f "$tmp_sel"
            return
            ;;
        esac
    done

    if [ ! -s "$tmp_sel" ]; then
        echo "${L_INFO_GH_NO_REPOS_SELECTED}"
        rm -f "$tmp_sel"
        sleep 1
        return
    fi

    local new_repos="    local REPOS=(\n"
    while read -r line; do
        new_repos+="        \"$line\"\n"
    done <"$tmp_sel"
    new_repos+="    )"
    rm -f "$tmp_sel"

    sed -i.bak -e "/local REPOS=(/,/)/c\\$new_repos" "$script_path"
    rm -f "$HOME/.cache/fastfetch/github_stars.cache"

    echo -e "${FG_GREEN}${L_SUCCESS_GH_STARS_CONFIGURED}${RESET}"
    sleep 1
}

configure_news_module() {
    clear
    echo -e "${BOLD}${L_INFO_CONFIGURE_NEWS_HEADER}${RESET}"
    local news_config_dir="$HOME/.config/fastfetch"
    local source_file="$news_config_dir/news.source"
    mkdir -p "$news_config_dir"

    echo "${L_INFO_NEWS_SELECT_SOURCE}"
    echo "  1. ${L_INFO_NEWS_SOURCE_1}"
    echo "  2. ${L_INFO_NEWS_SOURCE_2}"
    echo "  3. ${L_INFO_NEWS_SOURCE_3}"
    echo "  4. ${L_INFO_NEWS_SOURCE_4}"

    tput cnorm
    read -rp "$(echo -e "\n${BOLD}${L_PROMPT_NEWS_SOURCE}${RESET} ")" choice
    case $choice in
    1) new_source="opennet" ;;
    2) new_source="phoronix" ;;
    3) new_source="lwn" ;;
    4) return ;;
    *)
        echo -e "${FG_RED}${L_ERROR_INVALID_CHOICE}${RESET}"
        return
        ;;
    esac
    echo "$new_source" >"$source_file"
    echo -e "${FG_GREEN}${L_SUCCESS_NEWS_SOURCE_SAVED}${RESET}"
    sleep 1
}

configure_currency_module() {
    clear
    echo -e "${BOLD}${L_INFO_CONFIGURE_CURRENCY_HEADER}${RESET}"
    local config_dir="$HOME/.config/fastfetch"
    local config_file="$config_dir/currency.conf"
    mkdir -p "$config_dir"

    echo "${L_INFO_CURRENCY_SELECT_SOURCE}"
    echo "  1. ${L_INFO_CURRENCY_SOURCE_1}"
    echo "  2. ${L_INFO_CURRENCY_SOURCE_2}"
    echo "  3. ${L_INFO_NEWS_SOURCE_4}"

    tput cnorm
    read -rp "$(echo -e "\n${BOLD}${L_PROMPT_NEWS_SOURCE}${RESET} ")" choice
    case $choice in
    1)
        new_source="CBR"
        read -rp "$(echo -e "${L_INFO_CURRENCY_PROMPT_CBR}")" code
        [ -z "$code" ] && return
        new_pair="${code^^}/RUB"
        ;;
    2)
        new_source="ECB"
        read -rp "$(echo -e "${L_INFO_CURRENCY_PROMPT_ECB_FROM}")" from
        read -rp "$(echo -e "${L_INFO_CURRENCY_PROMPT_ECB_TO}")" to
        [ -z "$from" ] || [ -z "$to" ] && return
        new_pair="${from^^}/${to^^}"
        ;;
    3) return ;;
    *)
        echo -e "${FG_RED}${L_ERROR_INVALID_CHOICE}${RESET}"
        return
        ;;
    esac

    echo "SOURCE=\"$new_source\"" >"$config_file"
    echo "PAIR=\"$new_pair\"" >>"$config_file"
    echo -e "${FG_GREEN}${L_SUCCESS_CURRENCY_CONFIGURED}${RESET}"
    sleep 1
}
