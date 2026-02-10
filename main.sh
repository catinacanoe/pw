#!/usr/bin/env bash

echo >> ~/dl/pw.log
echo "$(date +"%H:%M @ %S.%3N") - beggining of main.sh" >> ~/dl/pw.log

MAP_FILE_SEPARATOR=" /// "
MAP_FILE="$PASSWORD_STORE_DIR/.map"

pw_dir="$(dirname "$0")"
flag="$1"
cd "$pw_dir" || exit

[ "$flag" == "-h" ] || [ "$flag" == "--help" ] && cat "./README.md" && exit

if [ "$flag" == "-i" ] || [ "$flag" == "--interactive" ]; then interactive='true'
                                                          else interactive=''; fi

echo "$(date +"%H:%M @ %S.%3N") - fetching window class & title" >> ~/dl/pw.log


class="$(hyprctl activewindow -j | jq -r .class)"
title="$(hyprctl activewindow -j | jq -r .title)"

password_folder_name="$(
    awk -F "$MAP_FILE_SEPARATOR" -v c="$class" t="$title"
    )"

notify-send "$password_folder_name"

# to prevent error spam below (TODO DELETE)
echo "$interactive"
echo "$MAP_FILE_SEPARATOR"
