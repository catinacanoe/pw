#!/usr/bin/env bash

original_dir="$PWD"
menu="$MENU"
pass_store="$PASSWORD_STORE_DIR"

map="$(cat $pass_store/.map | sed -e '/^\s*$/d' -e '/^\s*#/d')"
mapsep=" /// "
class="$(hyprctl activewindow -j | jq .class | sed -e 's/^"//' -e 's/"$//')"
title="$(hyprctl activewindow -j | jq .title | sed -e 's/^"//' -e 's/"$//')"
[ "$class" == "$BROWSER" ] && app="browser"
[ "$class" == "$TERMINAL" ] && app="terminal"
[ "$class" == "$EDITOR" ] && app="editor"

# grep to find the pass entry that matches input, then print its contents
pass_type() {
    if [ -z "$(ls "$pass_store" | grep "^$pass_folder$")" ]; then
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

    wtype "$(pass "$pass_folder/$(echo "$pass_entry" | sed 's/\.gpg$//')")"
}

wkey() {
    wtype -P "$1" -p "$1"
}
