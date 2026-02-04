#!/usr/bin/env bash

SCHEMA_LINE=""
CONFIG_JSON=""

declare -A SCRIPT_DEPENDENCIES=(
    ["github_stars.sh"]="gh jq"
    ["vram_info.sh"]="nvidia-smi"
    ["ram_specs.sh"]="inxi"
    ["disk_info.sh"]="lsblk df findmnt"
    ["network_speed.sh"]="curl"
    ["browser_info.sh"]="ps pgrep"
    ["usd_rub_rate.sh"]="curl xmlstarlet"
    ["news.sh"]="curl iconv xmlstarlet"
    ["media_art.sh"]="playerctl chafa"
    ["media_info.sh"]="playerctl"
    ["media_underline.sh"]="playerctl"
    ["ori_info.sh"]="xrandr"
    ["last_update.sh"]="grep date"
)

get_paths() {
    local base_path="$PROJECT_ROOT"
    if [ -f "$INSTALLED_FLAG" ]; then
        base_path="$CONFIG_DIR"
    fi
    echo "CONFIG_PATH=${base_path}/${CONFIG_FILE_NAME}"
    echo "SCRIPTS_PATH=${base_path}/${SCRIPTS_DIR_NAME}"
    echo "DEFAULT_CONFIG_PATH=${base_path}/${DEFAULT_CONFIG_FILE_NAME}"
    echo "CONFIG_BACKUP_PATH=${base_path}/${CONFIG_BACKUP_FILE_NAME}"
    echo "LAUNCHER_PATH=${base_path}/${LAUNCHER_NAME}"
}

ensure_jq() {
    if ! command -v jq &>/dev/null; then
        echo -e "${FG_RED}${BOLD}${L_ERROR_PREFIX}${RESET}${FG_RED} ${L_ERROR_JQ_NOT_FOUND}${RESET}"
        echo -e "${L_ERROR_JQ_INSTALL_HINT}"
        exit 1
    fi
}

load_config() {
    eval "$(get_paths)"

    if [ ! -f "$CONFIG_PATH" ]; then
        echo -e "${FG_RED}${BOLD}${L_ERROR_PREFIX}${RESET}${FG_RED} ${L_ERROR_CONFIG_NOT_FOUND}${RESET}"
        exit 1
    fi
    SCHEMA_LINE=$(grep '^\s*"$schema"' "$CONFIG_PATH" | sed 's/,$//' | sed 's/^[[:space:]]*//')
    CONFIG_JSON=$(grep -v -e '^\s*//' -e '^\s*"$schema"' "$CONFIG_PATH")
}

save_config() {
    eval "$(get_paths)"

    echo "${L_INFO_SAVING}"
    cp "$CONFIG_PATH" "$CONFIG_BACKUP_PATH"
    local schema_to_insert
    if [ -n "$SCHEMA_LINE" ]; then schema_to_insert="    ${SCHEMA_LINE},"; fi
    jq '.' <<<"$CONFIG_JSON" | sed "1a\\$schema_to_insert" >"$CONFIG_PATH"
    echo -e "${FG_GREEN}${BOLD}${L_SUCCESS_PREFIX}${RESET} ${L_SUCCESS_CONFIG_SAVED}"
}

reset_config() {
    eval "$(get_paths)"

    if [ ! -f "$DEFAULT_CONFIG_PATH" ]; then
        echo -e "${FG_RED}${BOLD}${L_ERROR_PREFIX}${RESET}${FG_RED} ${L_ERROR_DEFAULT_CONFIG_NOT_FOUND}${RESET}"
        return
    fi

    tput cnorm
    read -rp "$(echo -e "${L_PROMPT_RESET_CONFIRM}")" confirm
    if [[ "$confirm" != "y" ]]; then
        echo "${L_INFO_CANCEL}"
        return
    fi

    local user_backup_file="${CONFIG_DIR}/${CONFIG_FILE_NAME}.before_reset_$(date +%Y%m%d_%H%M%S)"
    cp "$CONFIG_PATH" "$user_backup_file"

    cp "$DEFAULT_CONFIG_PATH" "$CONFIG_PATH"

    echo -e "${FG_GREEN}${L_SUCCESS_CONFIG_RESET}${RESET}"
    echo -e "${L_INFO_BACKUP_SAVED_TO}"

    load_config
}

check_script_dependencies() {
    local required_tools=()
    local missing_tools=()
    local used_scripts_paths
    local current_config_path

    if [ -f "$INSTALLED_FLAG" ]; then
        current_config_path="${CONFIG_DIR}/${CONFIG_FILE_NAME}"
    else
        current_config_path="${PROJECT_ROOT}/${CONFIG_FILE_NAME}"
    fi

    local current_config_json_content=$(grep -v -e '^\s*//' -e '^\s*"$schema"' "$current_config_path")

    used_scripts_paths=$(jq -r '.modules[] | select(type=="object" and .type=="command") | .text' <<<"$current_config_json_content" | grep -v 'null')

    while IFS= read -r script_path_full; do
        script_name=$(echo $(basename "$script_path_full") | awk '{print $1}')

        if [ -n "${SCRIPT_DEPENDENCIES[$script_name]}" ]; then
            for tool in ${SCRIPT_DEPENDENCIES[$script_name]}; do
                if ! [[ " ${required_tools[@]} " =~ " ${tool} " ]]; then
                    required_tools+=("$tool")
                fi
            done
        fi
    done <<<"$used_scripts_paths"

    for tool in "${required_tools[@]}"; do
        if ! command -v "$tool" &>/dev/null; then
            missing_tools+=("$tool")
        fi
    done

    if [ ${#missing_tools[@]} -gt 0 ]; then
        echo -e "${L_INFO_DEPENDENCIES_WARNING_HEADER}"
        for tool in "${missing_tools[@]}"; do
            echo -e "  - ${FG_RED}$tool${RESET}"
        done
        echo -e "${L_INFO_DEPENDENCIES_WARNING_FOOTER}"
        return 1
    fi
    echo -e "${FG_GREEN}OK!${RESET}"
    return 0
}

get_module_label() {
    local module_json="$1"
    local output_line="Unknown Module"

    if [[ "$module_json" == \"*\" ]]; then
        local module_string
        module_string=$(jq -r . <<<"$module_json")
        [[ "$module_string" == "break" ]] && output_line="[ break ]" || output_line="--- $module_string ---"
    elif [[ "$module_json" == \{*\} ]]; then
        local module_type
        module_type=$(echo "$module_json" | jq -r '.type // "unknown"')

        if [[ "$module_type" == "custom" ]]; then
            local format
            format=$(echo "$module_json" | jq -r '.format // ""')
            [[ "$format" == *"──"* ]] && output_line="--- ${L_INFO_SEPARATOR} ---" || output_line="$format"
        elif [[ "$module_type" == "command" ]]; then
            local text
            text=$(echo "$module_json" | jq -r '.text // ""')
            local key
            key=$(echo "$module_json" | jq -r '.key // ""')

            local script_base_name
            script_base_name=$(echo $(basename "$text") | awk '{print $1}' | sed 's/\.sh$//')

            local icon=""
            if [[ -f "${SCRIPTS_PATH}/${script_base_name}.sh" ]]; then
                icon=$(grep --color=never '^ICON=' "${SCRIPTS_PATH}/${script_base_name}.sh" | cut -d'"' -f2 2>/dev/null || echo "")
            fi

            local display_name=""
            if [[ "$key" == " " ]]; then
                [[ -n "$icon" ]] && display_name="$icon $script_base_name" || display_name="└─ $script_base_name"
            else
                display_name="$key"
            fi

            output_line="$display_name"
        else
            local key
            key=$(echo "$module_json" | jq -r '.key // ""')
            if [ -z "$key" ]; then
                key=$(echo "$module_type" | sed 's/./\U&/')
            fi
            output_line="$key ($module_type)"
        fi
    fi
    echo "$output_line" | sed 's/\x1b\[[0-9;]*m//g'
}

list_modules() {
    eval "$(get_paths)"
    echo -e "${BOLD}${L_INFO_MODULES_HEADER}${RESET}"

    jq -c '.modules[]' <<<"$CONFIG_JSON" | while IFS= read -r module_json; do
        if [[ "$module_json" == "null" ]]; then continue; fi
        local label
        label=$(get_module_label "$module_json")
        echo "$label"
    done | nl -w2 -s'. '
    echo "---------------------------------------"
}

SELECTED_TUI_ITEM=""

select_script_tui() {
    local scripts=("${@}")
    local count=${#scripts[@]}
    local cur=0
    SELECTED_TUI_ITEM=""

    tput civis

    while true; do
        local win_height=$(tput lines)
        local header_height=5
        local list_height=$((win_height - header_height))

        local start_idx=0
        if ((count > list_height)); then
            if ((cur > list_height / 2)); then start_idx=$((cur - list_height / 2)); fi
            if ((start_idx + list_height > count)); then start_idx=$((count - list_height)); fi
        fi

        tput home
        echo -e "${L_TUI_ADD_MODULE_TITLE}\033[K"
        echo -e "  ────────────────────────────────────────────────────────────\033[K"
        echo -e "${L_TUI_NAVIGATION_HINT}\033[K"
        echo -e "  ────────────────────────────────────────────────────────────\033[K"

        for ((i = start_idx; i < start_idx + list_height && i < count; i++)); do
            if [ $i -eq $cur ]; then
                echo -e "  ${FG_GREEN}${BOLD} ➜ ${scripts[i]}${RESET}\033[K"
            else
                echo -e "     ${scripts[i]}\033[K"
            fi
        done
        tput ed

        IFS= read -rsn1 key
        if [[ $key == $'\x1b' ]]; then
            read -rsn2 -t 0.001 rest
            if [[ "$rest" == "" ]]; then return 1; fi
            case "$rest" in
            '[A') ((cur > 0)) && ((cur--)) ;;
            '[B') ((cur < count - 1)) && ((cur++)) ;;
            esac
        else
            case "$key" in
            "")
                SELECTED_TUI_ITEM="${scripts[cur]}"
                return 0
                ;;
            "q" | "Q") return 1 ;;
            esac
        fi
    done
}

edit_modules() {
    eval "$(get_paths)"

    local raw_modules=()
    local display_labels=()

    load_arrays() {
        raw_modules=()
        display_labels=()
        while IFS= read -r line; do
            if [[ "$line" != "null" && -n "$line" ]]; then
                raw_modules+=("$line")
                display_labels+=("$(get_module_label "$line")")
            fi
        done < <(echo "$CONFIG_JSON" | jq -c '.modules[]')
    }

    load_arrays
    local cur=0
    local is_moving=false
    tput civis

    while true; do
        local count=${#raw_modules[@]}

        if ((count > 0)); then
            ((cur >= count)) && cur=$((count - 1))
            ((cur < 0)) && cur=0
        else
            cur=0
        fi

        local win_height=$(tput lines)
        local header_height=5
        local list_height=$((win_height - header_height))

        local start_idx=0
        if ((count > list_height)); then
            if ((cur > list_height / 2)); then start_idx=$((cur - list_height / 2)); fi
            if ((start_idx + list_height > count)); then start_idx=$((count - list_height)); fi
        fi

        tput home
        echo -e "${L_TUI_EDIT_MODULE_TITLE}\033[K"
        echo -e "  ────────────────────────────────────────────────────────────\033[K"

        if $is_moving; then
            printf "${L_TUI_MOVING_STATUS}\033[K\n" "${display_labels[cur]}"
            echo -e "${L_TUI_MOVING_HINT}\033[K"
        else
            printf "${L_TUI_NAVIGATION_STATUS}\033[K\n" "$count"
            echo -e "${L_TUI_ACTION_HINT}\033[K"
        fi
        echo -e "  ────────────────────────────────────────────────────────────\033[K"

        if ((count == 0)); then
            echo -e "${L_TUI_EMPTY_LIST}\033[K"
        fi

        for ((i = start_idx; i < start_idx + list_height && i < count; i++)); do
            if [ $i -eq $cur ]; then
                if $is_moving; then
                    echo -e "  ${FG_YELLOW}${BOLD} ➜ [ ${display_labels[i]} ]${RESET}\033[K"
                else
                    echo -e "  ${FG_BLUE}${BOLD} ➜ ${display_labels[i]}${RESET}\033[K"
                fi
            else
                echo -e "     ${display_labels[i]}\033[K"
            fi
        done
        tput ed

        IFS= read -rsn1 key
        if [[ $key == $'\x1b' ]]; then
            read -rsn2 -t 0.001 rest
            if [[ "$rest" == "" ]]; then
                if $is_moving; then is_moving=false; else
                    tput cnorm
                    return
                fi
            fi
            case "$rest" in
            '[A')
                if $is_moving && ((cur > 0)); then
                    local tr="${raw_modules[cur]}"
                    raw_modules[cur]="${raw_modules[cur - 1]}"
                    raw_modules[cur - 1]="$tr"
                    local tl="${display_labels[cur]}"
                    display_labels[cur]="${display_labels[cur - 1]}"
                    display_labels[cur - 1]="$tl"
                    ((cur--))
                elif ! $is_moving && ((cur > 0)); then ((cur--)); fi
                ;;
            '[B')
                if $is_moving && ((cur < count - 1)); then
                    local tr="${raw_modules[cur]}"
                    raw_modules[cur]="${raw_modules[cur + 1]}"
                    raw_modules[cur + 1]="$tr"
                    local tl="${display_labels[cur]}"
                    display_labels[cur]="${display_labels[cur + 1]}"
                    display_labels[cur + 1]="$tl"
                    ((cur++))
                elif ! $is_moving && ((cur < count - 1)); then ((cur++)); fi
                ;;
            esac
        else
            local char=$(echo "$key" | tr '[:upper:]' '[:lower:]')
            case "$char" in
            "")
                if ((count > 0)); then
                    is_moving=$([[ "$is_moving" == "true" ]] && echo "false" || echo "true")
                fi
                ;;
            "d")
                if ! $is_moving && ((count > 0)); then
                    unset "raw_modules[cur]"
                    unset "display_labels[cur]"
                    raw_modules=("${raw_modules[@]}")
                    display_labels=("${display_labels[@]}")
                fi
                ;;
            "a")
                if ! $is_moving; then
                    local scripts=($(find "$SCRIPTS_PATH" -maxdepth 1 -type f -name "*.sh" -printf "%f\n" | sort))

                    select_script_tui "${scripts[@]}"
                    local res=$?

                    clear

                    if [[ $res -eq 0 && -n "$SELECTED_TUI_ITEM" ]]; then
                        local new_m=$(jq -n --arg t "\$HOME/.config/fastfetch/scripts/$SELECTED_TUI_ITEM" '{type: "command", key: " ", text: $t}')
                        local new_label=$(get_module_label "$new_m")

                        local ins_idx=$cur
                        if ((count > 0)); then ins_idx=$((cur + 1)); fi

                        raw_modules=("${raw_modules[@]:0:ins_idx}" "$new_m" "${raw_modules[@]:ins_idx}")
                        display_labels=("${display_labels[@]:0:ins_idx}" "$new_label" "${display_labels[@]:ins_idx}")

                        cur=$ins_idx
                        is_moving=true
                    fi
                    tput civis
                fi
                ;;
            "s")
                if ! $is_moving; then
                    break
                fi
                ;;
            "q")
                if ! $is_moving; then
                    tput cnorm
                    return
                fi
                ;;
            esac
        fi
    done

    tput cnorm
    clear
    echo -e "${L_INFO_SAVING}"
    local tmp=$(mktemp)
    echo "[" >"$tmp"
    for ((i = 0; i < ${#raw_modules[@]}; i++)); do
        echo "${raw_modules[i]}" >>"$tmp"
        ((i < ${#raw_modules[@]} - 1)) && echo "," >>"$tmp"
    done
    echo "]" >>"$tmp"
    CONFIG_JSON=$(jq --argjson nm "$(cat "$tmp")" '.modules = $nm' <<<"$CONFIG_JSON")
    rm "$tmp"
    save_config
    sleep 0.5
}
