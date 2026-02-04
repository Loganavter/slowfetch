#!/usr/bin/env bash

ICON=""

if [[ "$LANG" =~ ^ru ]]; then
    ERROR_CURL_XMLSTARLET_REQUIRED="требуется curl/xmlstarlet"
    ERROR_BC_REQUIRED="bc требуется для ECB"
    ERROR_NOT_FOUND="Не найдено"
    ERROR_UNKNOWN_SOURCE="Неизвестный источник"
else
    ERROR_CURL_XMLSTARLET_REQUIRED="curl/xmlstarlet required"
    ERROR_BC_REQUIRED="bc required for ECB"
    ERROR_NOT_FOUND="Not found"
    ERROR_UNKNOWN_SOURCE="Unknown source"
fi

if ! command -v curl &>/dev/null || ! command -v xmlstarlet &>/dev/null; then
    echo "$ERROR_CURL_XMLSTARLET_REQUIRED"
    exit 1
fi

CONFIG_DIR="$HOME/.config/fastfetch"
CONFIG_FILE="$CONFIG_DIR/currency.conf"

DEFAULT_SOURCE="CBR"
DEFAULT_PAIR="USD/RUB"

mkdir -p "$CONFIG_DIR"
if [ ! -f "$CONFIG_FILE" ]; then
    echo "SOURCE=\"$DEFAULT_SOURCE\"" >"$CONFIG_FILE"
    echo "PAIR=\"$DEFAULT_PAIR\"" >>"$CONFIG_FILE"
fi

source "$CONFIG_FILE"

case "$SOURCE" in
"CBR")
    TARGET_CURRENCY=$(echo "$PAIR" | cut -d'/' -f1)

    RATE=$(curl -s "http://www.cbr.ru/scripts/XML_daily.asp" |
        xmlstarlet sel -t -v "//Valute[CharCode='$TARGET_CURRENCY']/Value" -n |
        sed 's/,/./')

    if [ -n "$RATE" ]; then
        LC_NUMERIC=C printf "%.2f\n" "$RATE"
    else
        echo "$ERROR_NOT_FOUND"
    fi
    ;;

"ECB")
    if ! command -v bc &>/dev/null; then
        echo "$ERROR_BC_REQUIRED"
        exit 1
    fi

    CURRENCY_FROM=$(echo "$PAIR" | cut -d'/' -f1)
    CURRENCY_TO=$(echo "$PAIR" | cut -d'/' -f2)

    XML_DATA=$(curl -s "https://www.ecb.europa.eu/stats/eurofxref/eurofxref-daily.xml" | sed -e 's/ xmlns=.*"//' -e 's/gesmes://g' -e 's/eurofxref://g')

    RATE_FROM=$(echo "$XML_DATA" | xmlstarlet sel -t -v "//Cube[@currency='$CURRENCY_FROM']/@rate" 2>/dev/null)
    RATE_TO=$(echo "$XML_DATA" | xmlstarlet sel -t -v "//Cube[@currency='$CURRENCY_TO']/@rate" 2>/dev/null)

    [ "$CURRENCY_FROM" == "EUR" ] && RATE_FROM="1"
    [ "$CURRENCY_TO" == "EUR" ] && RATE_TO="1"

    if [ -n "$RATE_FROM" ] && [ -n "$RATE_TO" ]; then
        RESULT=$(echo "scale=4; $RATE_TO / $RATE_FROM" | bc | sed 's/^\./0./')

        LC_NUMERIC=C printf "%.3f\n" "$RESULT"
    else
        echo "$ERROR_NOT_FOUND"
    fi
    ;;

*)
    echo "$ERROR_UNKNOWN_SOURCE"
    exit 1
    ;;
esac
