#!/bin/bash

ICON=""

if ! command -v playerctl &>/dev/null; then
    echo "No media"
    exit 1
fi

playerctl metadata --format '{{artist}} - {{title}} ({{status}})' || echo 'No media'
