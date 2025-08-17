#!/bin/bash

ICON="🎵"

art_url=$(playerctl metadata mpris:artUrl 2>/dev/null)

if [ -z "$art_url" ]; then
    exit 1
fi

art_path=$(echo "$art_url" | sed 's|^file://||')

if [ ! -f "$art_path" ]; then
    exit 1
fi

chafa -s 60x80 "$art_path" | awk '{print "  "$0}'
