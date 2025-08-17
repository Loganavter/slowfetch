#!/bin/bash

ICON="$"

KEY_COLOR="\033[1;32m"
RESET_COLOR="\033[0m"

INDENT="  "

if [[ "$LANG" =~ ^ru ]]; then
    SCRIPT_ERROR_MSG="Ошибка скрипта"
else
    SCRIPT_ERROR_MSG="Script Error"
fi

CONFIG_FILE="$HOME/.config/fastfetch/currency.conf"
RATE_SCRIPT="$HOME/.config/fastfetch/scripts/currency_rate.sh"

if [ -f "$CONFIG_FILE" ]; then
    source "$CONFIG_FILE"
else
    PAIR="USD/RUB"
fi

if [ ! -x "$RATE_SCRIPT" ]; then
    echo -e "${KEY_COLOR}${INDENT}${ICON} Currency${RESET_COLOR} : ${SCRIPT_ERROR_MSG}"
    exit 1
fi

rate=$("$RATE_SCRIPT")

formatted_key="${KEY_COLOR}${INDENT}${ICON} ${PAIR}${RESET_COLOR}"

echo -e "${formatted_key} : ${rate}"
