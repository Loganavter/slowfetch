#!/bin/bash

ICON=""

if ! command -v inxi &>/dev/null; then
    exit 1
fi

COLOR_TITLE="\033[0;38;2;170;130;255m"
COLOR_RESET="\033[0m"

inxi -m | awk '
/Device/ && !/no module installed/ {
    match($0, /type: ([A-Z0-9]+[0-9]*)/, mtype);
    match($0, /size: ([0-9]+) GiB/, msize);
    match($0, /speed: ([0-9]+) MT\/s/, mfreq);
    if (length(msize) > 0) {
        key = msize[1];
        size[key]++;
        if (!type_found) { type_found = mtype[1] };
        if (!speed_found && length(mfreq) > 0) { speed_found = mfreq[1] };
    }
}
/actual:/ {
    if (!speed_found) {
        match($0, /actual: ([0-9]+) MT\/s/, mactual);
        if (length(mactual) > 0) { speed_found = mactual[1] };
    }
}
END {
    if (!type_found) exit 1;
    
    split("", size_arr);
    for (key in size) {
        size_arr[key] = key "x" size[key];
    }
    asort(size_arr, sorted_arr, "@val_num_desc");
    
    size_string = "";
    for (i in sorted_arr) {
        size_string = size_string sorted_arr[i] " ";
    }
    
    printf "%s     Specs %s: %s %sGiB %.2f GHz\n",
        "\033[0;38;2;170;130;255m",
        "\033[0m",
        type_found,
        size_string,
        (speed_found ? speed_found / 1000 : 0)
}
'
