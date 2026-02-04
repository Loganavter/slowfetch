#!/usr/bin/env bash

VISUALIZE=false

C_RESET="\033[0m"
C_KEY="\033[1;33m"
C_ARROW="\033[1;31m"
ICON="󰍽"

log_viz() {
    if [ "$VISUALIZE" = true ]; then
        echo -e "  ${C_ARROW}-->${C_RESET} $1"
    fi
}

if ! command -v udevadm &>/dev/null; then
    echo "Ошибка: udevadm не установлен." >&2
    exit 1
fi

mouse_devices=(/dev/input/mouse*)
if [ ! -e "${mouse_devices[0]}" ]; then
    log_viz "Устройств /dev/input/mouse* не найдено."
    exit 1
fi

KEY_PREFIX="${C_KEY}${ICON} Mouse${C_RESET}"
MOUSE_NAMES=()
PROCESSED_IDS=()

for m in "${mouse_devices[@]}"; do
    unset ID_INPUT_MOUSE ID_INPUT_TABLET ID_VENDOR_ID ID_MODEL_ID ID_SERIAL ID_PATH ID_BUS DEVPATH NAME

    eval "$(udevadm info --query=property --name="$m" --export)"

    if [ "$ID_INPUT_MOUSE" != "1" ] || [ "$ID_INPUT_TABLET" = "1" ]; then
        continue
    fi

    if [ -z "$ID_BUS" ] || [[ "$DEVPATH" == *"/virtual/"* ]]; then
        log_viz "Пропуск [$m]: Виртуальное устройство (пустой ID_BUS или путь /virtual/)."
        continue
    fi

    UNIQUE_ID="${ID_SERIAL:-$ID_PATH}"
    if [[ " ${PROCESSED_IDS[@]} " =~ " ${UNIQUE_ID} " ]]; then
        continue
    fi
    PROCESSED_IDS+=("$UNIQUE_ID")

    FINAL_NAME=""

    if [ -n "$ID_MODEL_FROM_DATABASE" ]; then
        FINAL_NAME="${ID_VENDOR_FROM_DATABASE:-$ID_VENDOR} $ID_MODEL_FROM_DATABASE"
    fi

    if [ -z "$FINAL_NAME" ] && [ -n "$ID_VENDOR_ID" ] && [ -n "$ID_MODEL_ID" ]; then
        LSUSB_NAME=$(lsusb -d "${ID_VENDOR_ID}:${ID_MODEL_ID}" 2>/dev/null)
        if [ -n "$LSUSB_NAME" ]; then
            FINAL_NAME=$(echo "$LSUSB_NAME" | sed -E 's/.*ID [0-9a-fA-F]+:[0-9a-fA-F]+ //; s/,? Ltd\.?//g; s/,? Co\.?//g; s/USB DEVICE//g; s/  */ /g; s/^ //; s/ $//')
        fi
    fi

    if [ -z "$FINAL_NAME" ]; then
        sys_name_path="/sys/class/input/${m##*/}/device/name"
        if [ -f "$sys_name_path" ]; then
            FINAL_NAME=$(cat "$sys_name_path" | sed 's/"//g' | xargs)
        fi
    fi

    if [ -z "$FINAL_NAME" ]; then
        FINAL_NAME=$(echo "${ID_VENDOR//_/ } ${ID_MODEL//_/ }" | xargs)
    fi

    [ -z "$FINAL_NAME" ] && FINAL_NAME="Unknown ${ID_BUS} Mouse"

    MOUSE_NAMES+=("$FINAL_NAME")
done

if [ ${#MOUSE_NAMES[@]} -gt 0 ]; then
    for name in "${MOUSE_NAMES[@]}"; do
        echo -e "  ${KEY_PREFIX} : ${name}"
    done
    exit 0
else
    exit 1
fi
