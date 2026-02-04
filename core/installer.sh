#!/usr/bin/env bash

write_alias_to_config() {
    local alias_name=$1
    local alias_command_value=$2
    local shell_name
    shell_name=$(basename "$SHELL")
    local config_file=""

    case "$shell_name" in
    bash) config_file="$HOME/.bashrc" ;;
    zsh) config_file="$HOME/.zshrc" ;;
    *)
        echo -e "${FG_RED}${L_ERROR_PREFIX} ${L_ERROR_SHELL_NOT_SUPPORTED}${RESET}"
        return
        ;;
    esac

    local alias_line="alias ${alias_name}='${alias_command_value}'"
    local alias_comment="# Alias for fastfetch, added by configurator"

    if [ ! -f "$config_file" ]; then
        echo "${L_INFO_ALIAS_CONFIG_CREATED}"
        touch "$config_file"
    fi

    sed -i.bak "/^${alias_comment}/d" "$config_file"
    sed -i.bak "/^alias ${alias_name}=/d" "$config_file"

    echo -e "\n${alias_comment}\n${alias_line}" >>"$config_file"
    echo -e "${FG_GREEN}${L_SUCCESS_ALIAS_CREATED}${RESET}"
}

remove_alias_from_config() {
    local alias_name=$1
    local shell_name
    shell_name=$(basename "$SHELL")
    local config_file=""

    case "$shell_name" in
    bash) config_file="$HOME/.bashrc" ;;
    zsh) config_file="$HOME/.zshrc" ;;
    *) return ;;
    esac

    if [ -f "$config_file" ]; then
        sed -i.bak -e "/# Alias for fastfetch, added by configurator/d" -e "/^alias ${alias_name}=/d" "$config_file"
    fi
}

prompt_to_reload_shell() {
    local shell_name
    shell_name=$(basename "$SHELL")
    local config_file=""

    case "$shell_name" in
    bash) config_file="$HOME/.bashrc" ;;
    zsh) config_file="$HOME/.zshrc" ;;
    *)
        echo -e "${L_INFO_ALIAS_APPLY_HINT}"
        echo -e "${L_INFO_ALIAS_RESTART_HINT}"
        return
        ;;
    esac

    local source_command="source ${config_file}"
    if [[ "$shell_name" == "zsh" ]]; then
        source_command="source ${config_file} && compinit"
    fi

    echo -e "${L_INFO_ALIAS_APPLY_HINT}\n  ${BOLD}${source_command}${RESET}\n${L_INFO_ALIAS_RESTART_HINT}"

    tput cnorm
    read -rp "$(echo -e "${L_PROMPT_RELOAD_SHELL}")" choice
    if [[ "$choice" == "y" || "$choice" == "Y" ]]; then
        echo "${L_INFO_RELOADING_SHELL}"

        if type cleanup_terminal &>/dev/null; then cleanup_terminal; fi

        exec "$SHELL"
    fi
}

create_alias() {
    local alias_name=$1
    local default_command=$2
    local alias_command_value="${default_command}"

    echo -e "\n${BOLD}${L_INFO_CREATING_ALIAS_HEADER}${RESET}"

    write_alias_to_config "$alias_name" "$alias_command_value"
}

create_config_alias() {
    eval "$(get_paths)"
    write_alias_to_config "slowfetch-config" "bash ${LAUNCHER_PATH}"
}

first_run_setup() {
    tput cnorm
    echo -e "${L_INSTALL_WELCOME}"
    echo "${L_INSTALL_FIRST_RUN}"

    echo -e "\n${L_INSTALL_DEP_CHECK}"
    if ! check_script_dependencies; then
        read -rp "$(echo -e "${L_PROMPT_CONTINUE_OR_EXIT}")" user_choice
        if [[ "$user_choice" == "exit" ]]; then
            echo "${L_INFO_EXITING}"
            exit 0
        fi
    fi

    echo -e "\n${L_INSTALL_ALIAS_SETUP}"
    create_alias "slowfetch" "fastfetch --logo none --ds-force-drm"

    echo -e "\n${L_INSTALL_PERFORMING}"
    perform_installation

    echo "   - ${L_INSTALL_CONFIG_ALIAS}"
    create_config_alias

    touch "$INSTALLED_FLAG"

    echo -e "${L_INSTALL_COMPLETE_HEADER}"
    echo "${L_INSTALL_COMPLETE_BODY}"
    echo -e "  - ${L_INSTALL_COMPLETE_ALIAS_SLOWFETCH}"
    echo -e "  - ${L_INSTALL_COMPLETE_ALIAS_CONFIG}"

    prompt_to_reload_shell
    exit 0
}

perform_installation() {
    if [[ "$PROJECT_ROOT" == "$CONFIG_DIR" ]]; then
        chmod +x "${CONFIG_DIR}/${LAUNCHER_NAME}"
        chmod +x "${CONFIG_DIR}/${SCRIPTS_DIR_NAME}/"*.sh
        chmod +x "${CONFIG_DIR}/core/"*.sh
        return
    fi

    mkdir -p "$CONFIG_DIR"

    if [ -n "$(ls -A "$CONFIG_DIR" 2>/dev/null)" ]; then
        echo "   - ${L_INSTALL_BACKING_UP}"
        local backup_dir="${CONFIG_DIR}/.backup_$(date +%Y%m%d_%H%M%S)"
        mkdir -p "$backup_dir"
        mv "$CONFIG_DIR"/* "$CONFIG_DIR"/.[!.]* "$backup_dir/" 2>/dev/null
    fi

    cp -a "$PROJECT_ROOT"/* "$CONFIG_DIR/"

    chmod +x "${CONFIG_DIR}/${LAUNCHER_NAME}"
    chmod +x "${CONFIG_DIR}/${SCRIPTS_DIR_NAME}/"*.sh
    chmod +x "${CONFIG_DIR}/core/"*.sh
    echo -e "${FG_GREEN}   OK!${RESET}"
}

uninstall_project() {
    tput cnorm
    echo -e "${FG_RED}${BOLD}${L_UNINSTALL_WARNING}${RESET}"
    read -rp "$(echo -e "${L_UNINSTALL_CONFIRM}")" confirm
    if [[ "$confirm" != "y" ]]; then
        echo "${L_INFO_CANCEL}"
        return
    fi

    echo -e "\n${L_UNINSTALL_STARTED}"

    echo -n "-> ${L_UNINSTALL_ALIASES} "
    remove_alias_from_config "slowfetch"
    remove_alias_from_config "slowfetch-config"
    echo -e "${FG_GREEN}OK${RESET}"

    echo "-> ${L_UNINSTALL_FILES}"
    local latest_backup_dir=$(find "$CONFIG_DIR" -maxdepth 1 -type d -name ".backup_*" | sort -r | head -n 1)

    if [ -n "$latest_backup_dir" ]; then
        echo "   - ${L_UNINSTALL_RESTORE}"
        local temp_cleanup_dir="${CONFIG_DIR}/.temp_cleanup_$(date +%s)"
        mkdir -p "$temp_cleanup_dir"
        find "$CONFIG_DIR" -mindepth 1 ! -wholename "$latest_backup_dir*" -exec mv -t "$temp_cleanup_dir" {} + 2>/dev/null

        mv "$latest_backup_dir"/* "$latest_backup_dir"/.[!.]* "$CONFIG_DIR/" 2>/dev/null

        rm -rf "$temp_cleanup_dir" "$latest_backup_dir"
    else
        echo "   - ${L_UNINSTALL_NO_BACKUP}"
        rm -rf "$CONFIG_DIR"
    fi

    CACHE_DIR="$HOME/.cache/fastfetch"
    CACHE_FILE="$CACHE_DIR/github_stars.cache"
    rm -f "$CACHE_FILE"
    echo -e "${L_INFO_CACHE_CLEARED}"

    echo -e "\n${FG_GREEN}${L_UNINSTALL_COMPLETE}${RESET}"
    echo "${L_UNINSTALL_GOODBYE}"
    prompt_to_reload_shell

    if [ -f "${CONFIG_DIR}/${LAUNCHER_NAME}" ]; then
        rm -f "${CONFIG_DIR}/${LAUNCHER_NAME}"
    fi

    exit 0
}
