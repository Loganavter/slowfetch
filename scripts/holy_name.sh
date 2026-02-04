#!/usr/bin/env bash

ICON="✞"

distro=$(grep '^ID_LIKE=' /etc/os-release | cut -d '=' -f 2 | tr -d '"')
if [ -z "$distro" ]; then
    distro=$(grep '^ID=' /etc/os-release | cut -d '=' -f 2 | tr -d '"')
fi

case $distro in
'debian') holy_name='Deusbian' ;;
'fedora') holy_name='Fideora' ;;
'arch') holy_name='Archangel' ;;
'freebsd') holy_name='SanctBSD' ;;
'nixos') holy_name='NixCovenant' ;;
'gentoo') holy_name='Genesis' ;;
'rhel') holy_name='SanctOS' ;;
'suse') holy_name='Opus Dei' ;;
*) holy_name=$distro ;;
esac

COLOR_GOLD="\033[1;38;2;255;215;0m"
COLOR_GOLD_BOLD="\033[1;38;2;255;215;0m"
COLOR_RESET="\033[0m"

name_len=${#holy_name}
padding_len=$(((25 - (13 + name_len) / 2)))
padding=$(printf '%*s' "$padding_len")

echo -e "${padding}${COLOR_GOLD}${COLOR_GOLD_BOLD}${ICON}${ICON}${ICON}${holy_name}${ICON}${ICON}${ICON}${COLOR_RESET}"
