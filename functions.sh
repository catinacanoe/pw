#!/usr/bin/env bash

export original_dir="$PWD"
export menu="$DMENU_PROGRAM"
export pass_store="$PASSWORD_STORE_DIR"

export map="$(cat $pass_store/.map | sed -e '/^\s*$/d' -e '/^\s*#/d')"
export mapsep=" /// "
export class="$(hyprctl activewindow -j | jq .class | sed -e 's/^"//' -e 's/"$//')"
export title="$(hyprctl activewindow -j | jq .title | sed -e 's/^"//' -e 's/"$//')"
[ "$class" == "$BROWSER" ] && export app="browser"
[ "$class" == "$TERMINAL" ] && export app="terminal"
[ "$class" == "$EDITOR" ] && export app="editor"

# grep to find the pass entry that matches input, then print its contents
pass_type() {
    if [ "$(ls "$pass_store" | grep -c "^$pass_folder$")" != "1" ]; then
        pass_folder="$(ls "$pass_store" | grep "^$pass_folder")"
        if [ "$(echo "$pass_folder" | wc -l)" != "1" ]; then
            pass_folder="$(echo "$pass_folder" | $menu)"
        fi
    fi
    [ -z "$pass_folder" ] && exit # if user clicks escape

    pass_entry="$(ls "$pass_store/$pass_folder" | grep "^$1")"
    if [ "$(echo "$pass_entry" | wc -l)" != "1" ]; then
	pass_entry="$(echo "$pass_entry" | sed 's/\.gpg$//' | $menu)"
    fi
    [ -z "$pass_entry" ] && exit # if user clicks escape

    wl-copy "$(pass "$pass_folder/$(echo "$pass_entry" | sed 's/\.gpg$//')")"
    wtype -M ctrl -k v -m ctrl
}

wkey() {
    wtype -P "$1" -p "$1"
}
