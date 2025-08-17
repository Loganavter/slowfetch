#!/bin/bash

ICON="󰍽"

MOUSE_DEVICE="/dev/input/mouse0"

if [ ! -e "$MOUSE_DEVICE" ]; then
    exit 1
fi

MODEL_ID=$(udevadm info --query=all --name=$MOUSE_DEVICE | grep 'ID_USB_MODEL_ID' | cut -d'=' -f2)

if [ -z "$MODEL_ID" ]; then
    exit 1
fi

MOUSE_NAME=$(lsusb | grep "$MODEL_ID" | cut -d ' ' -f 7- | awk -F', ' '{print $1}')

if [ -n "$MOUSE_NAME" ]; then
    echo "$MOUSE_NAME"
else
    exit 1
fi
