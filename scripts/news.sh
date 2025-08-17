#!/bin/bash

ICON=""

# Определение языка для сообщений об ошибках
if [[ "$LANG" =~ ^ru ]]; then
    ERROR_CURL_REQUIRED="требуется curl"
    ERROR_ICONV_REQUIRED="iconv требуется для opennet"
    ERROR_XMLSTARLET_REQUIRED_PHORONIX="xmlstarlet требуется для phoronix"
    ERROR_XMLSTARLET_REQUIRED_LWN="xmlstarlet требуется для lwn"
    ERROR_UNKNOWN_SOURCE="Неизвестный источник в конфиге: '$SOURCE'"
else
    ERROR_CURL_REQUIRED="curl required"
    ERROR_ICONV_REQUIRED="iconv required for opennet"
    ERROR_XMLSTARLET_REQUIRED_PHORONIX="xmlstarlet required for phoronix"
    ERROR_XMLSTARLET_REQUIRED_LWN="xmlstarlet required for lwn"
    ERROR_UNKNOWN_SOURCE="Unknown source in config: '$SOURCE'"
fi

CONFIG_DIR="$HOME/.config/fastfetch"
SOURCE_FILE="$CONFIG_DIR/news.source"

if [ -f "$SOURCE_FILE" ]; then
    SOURCE=$(cat "$SOURCE_FILE")
else
    SOURCE="opennet"
fi

if ! command -v curl &>/dev/null; then
    echo "$ERROR_CURL_REQUIRED"
    exit 1
fi

case "$SOURCE" in
opennet)
    if ! command -v iconv &>/dev/null; then
        echo "$ERROR_ICONV_REQUIRED"
        exit 1
    fi
    curl -s 'https://www.opennet.ru/opennews/' |
        iconv -f KOI8-R -t UTF-8 |
        grep -m 1 -oE '<a href="/opennews/art.shtml\?num=[0-9]+" class=title2>[^<]+</a>' |
        sed -E 's/.*>([^<]+)<.*/\1/'
    ;;

phoronix)
    if ! command -v xmlstarlet &>/dev/null; then
        echo "$ERROR_XMLSTARLET_REQUIRED_PHORONIX"
        exit 1
    fi
    curl -s "https://www.phoronix.com/rss.php" |
        xmlstarlet sel -t -v "//item[1]/title" -n
    ;;

lwn)
    if ! command -v xmlstarlet &>/dev/null; then
        echo "$ERROR_XMLSTARLET_REQUIRED_LWN"
        exit 1
    fi
    curl -s "https://lwn.net/headlines/rss" |
        xmlstarlet sel -t -v "//item[1]/title" -n
    ;;

*)
    echo "$ERROR_UNKNOWN_SOURCE"
    exit 1
    ;;
esac
