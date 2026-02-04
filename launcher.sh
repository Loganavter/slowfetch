#!/usr/bin/env bash

SOURCE="${BASH_SOURCE[0]}"
while [ -h "$SOURCE" ]; do
    DIR="$(cd -P "$(dirname "$SOURCE")" && pwd)"
    SOURCE="$(readlink "$SOURCE")"
    [[ $SOURCE != /* ]] && SOURCE="$DIR/$SOURCE"
done
PROJECT_ROOT="$(cd -P "$(dirname "$SOURCE")" && pwd)"
CORE_DIR="$PROJECT_ROOT/core"

CONFIG_DIR="$HOME/.config/fastfetch"
INSTALLED_FLAG="${CONFIG_DIR}/.installed"
CONFIG_FILE_NAME="config.jsonc"
SCRIPTS_DIR_NAME="scripts"
CONFIG_BACKUP_FILE_NAME="config.jsonc.bak"
DEFAULT_CONFIG_FILE_NAME="config.default.jsonc"
LAUNCHER_NAME="launcher.sh"

source "$CORE_DIR/ui.sh" &>/dev/null
source "$CORE_DIR/config_manager.sh" &>/dev/null
source "$CORE_DIR/configurators.sh" &>/dev/null
source "$CORE_DIR/installer.sh" &>/dev/null

CURRENT_MODE=0

mode_tui() {
    if [ "$CURRENT_MODE" -eq 0 ]; then
        tput smcup
        tput clear
        CURRENT_MODE=1
    else
        tput clear
    fi
}

mode_cli() {
    if [ "$CURRENT_MODE" -eq 1 ]; then
        tput clear
        tput rmcup
        CURRENT_MODE=0
    fi
}

cleanup() {
    printf '\e[?1000l\e[1006l'
    tput cnorm
    tput rmcup
    stty sane
    exit 0
}

trap cleanup SIGINT SIGTERM EXIT

show_menu() {
    tput home
    echo -e "${L_MAIN_MENU_TITLE}"
    echo "1. ${L_MAIN_MENU_1}"
    echo "2. ${L_MAIN_MENU_2}"
    echo "r. ${L_MAIN_MENU_R}"
    echo "a. ${L_MAIN_MENU_A}"
    echo "---------------------------------------"
    echo -e "${L_MAIN_MENU_U}"
    echo "---------------------------------------"
    echo -e "${L_MAIN_MENU_S}"
    echo -e "${L_MAIN_MENU_Q}"
    echo "---------------------------------------"
}

handle_action() {
    local key=$1

    case $key in
    1)
        edit_modules
        ;;
    2)
        while true; do
            tput cnorm
            clear
            echo -e "${L_SUBMENU_CONFIGURE_TITLE}"
            echo "1. ${L_SUBMENU_CONFIGURE_OPTION_1}"
            echo "2. ${L_SUBMENU_CONFIGURE_OPTION_2}"
            echo "3. ${L_SUBMENU_CONFIGURE_OPTION_3}"
            echo "--------------------------"
            echo "0. ${L_SUBMENU_CONFIGURE_BACK}"
            read -rp "${L_PROMPT_SUBMENU_CHOICE}" sub
            case $sub in
            1) configure_github_stars ;;
            2)
                clear
                configure_news_module
                sleep 1
                ;;
            3)
                clear
                configure_currency_module
                sleep 1
                ;;
            0) break ;;
            *)
                echo -e "${FG_RED}${L_ERROR_INVALID_CHOICE}${RESET}"
                sleep 1
                ;;
            esac
        done
        ;;
    r)
        clear
        tput cnorm
        reset_config
        press_enter_to_continue
        ;;
    a)
        clear
        tput cnorm
        create_alias "slowfetch" "fastfetch --logo none --ds-force-drm"
        prompt_to_reload_shell
        ;;
    u)
        mode_cli
        uninstall_project
        exit 0
        ;;
    s)
        save_config
        exit 0
        ;;
    q) exit 0 ;;
    esac
}

if [ ! -f "$INSTALLED_FLAG" ]; then
    if [[ "$PROJECT_ROOT" != "$CONFIG_DIR" ]]; then
        first_run_setup
    fi
fi

ensure_jq
load_config

tput cnorm

while true; do
    mode_tui
    show_menu

    tput cnorm
    read -rp "$(echo -e "${BOLD}${L_PROMPT_CHOOSE_ACTION}${RESET} ")" choice

    choice=$(echo "$choice" | tr '[:upper:]' '[:lower:]')

    tput civis
    handle_action "$choice"
done
