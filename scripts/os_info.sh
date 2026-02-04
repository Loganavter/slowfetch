#!/usr/bin/env bash

ICON=""

distro_id=$(grep '^ID=' /etc/os-release | cut -d '=' -f 2 | tr -d '"')
distro_like=$(grep '^ID_LIKE=' /etc/os-release | cut -d '=' -f 2 | tr -d '"')
distro_name=$(grep '^NAME=' /etc/os-release | cut -d '=' -f 2 | tr -d '"')
arch=$(uname -m)

distro_check="${distro_like:-$distro_id}"

COLOR_RED="\033[1;91m"
COLOR_RESET="\033[0m"

ICON_DEBIAN=""
ICON_FEDORA=""
ICON_FREEBSD=""
ICON_GENTOO=""
ICON_NIXOS=""
ICON_OPENSUSE=""
ICON_RHEL="󱄛"
ICON_ARCH=""
ICON_DEFAULT=""

case "$distro_check" in
*debian*) icon="$ICON_DEBIAN" ;;
*fedora*) icon="$ICON_FEDORA" ;;
*freebsd*) icon="$ICON_FREEBSD" ;;
*gentoo*) icon="$ICON_GENTOO" ;;
*nixos*) icon="$ICON_NIXOS" ;;
*opensuse*) icon="$ICON_OPENSUSE" ;;
*rhel*) icon="$ICON_RHEL" ;;
*arch*) icon="$ICON_ARCH" ;;
*) icon="$ICON_DEFAULT" ;;
esac

echo -e "${COLOR_RED}  ${icon} OS${COLOR_RESET} : $distro_name $arch"
