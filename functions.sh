#!/usr/bin/env bash

echo "$(date +"%H:%M @ %S.%3N") - beggining export of map, class, title vars" >> ~/dl/pw.log

export original_dir="$PWD"
export menu="$DMENU_PROGRAM"
export pass_store="$PASSWORD_STORE_DIR"

export map="$(cat $pass_store/.map | sed -e '/^\s*$/d' -e '/^\s*#/d')"
export mapsep=" /// "
export class="$(hyprctl activewindow -j | jq .class | sed -e 's/^"//' -e 's/"$//')"
if [ "$class" == "org.qutebrowser.qutebrowser" ]; then
    export title="$(hyprctl activewindow -j | jq .title | sed -e 's/^"//' -e 's/"$//' -e 's/ - qutebrowser$//') $(browser get-url | sed -e 's|^[^/]*//\([^/]*\)/.*|\[\1\]|') - qutebrowser"
else
    export title="$(hyprctl activewindow -j | jq .title | sed -e 's/^"//' -e 's/"$//')"
fi

echo "$(date +"%H:%M @ %S.%3N") - finished export of map, class, title vars" >> ~/dl/pw.log

# [ "$class" == "$BROWSER" ] && export app="browser"
# [ "$class" == "$TERMINAL" ] && export app="terminal"
# [ "$class" == "$EDITOR" ] && export app="editor"
echo -e "$BROWSER\n$BROWSERS" | grep -q "^$class$" && export app="browser"
echo -e "$TERMINAL\n$TERMINALS" | grep -q "^$class$" && export app="terminal"
echo -e "$EDITOR\n$EDITORS" | grep -q "^$class$" && export app="editor"

# grep to find the pass entry that matches input, then print its contents
pass_type() {
    echo "$(date +"%H:%M @ %S.%3N") - begin pass_type()" >> ~/dl/pw.log

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

    gpgfile="$(find "$HOME/.pass" | grep 'user\.gpg$' | head -n 1)"

    while [ -z "$(gpg --pinentry-mode cancel --quiet -d "$gpgfile" | grep -v "^gpg:.*failed: Operation cancelled")" ]; do
        rm /tmp/gpgpass
        pypr show gpgpass
        while [ ! -f "/tmp/gpgpass" ]; do
            sleep 0.1
        done
        rm /tmp/gpgpass
    done

    wl-copy "$(pass "$pass_folder/$(echo "$pass_entry" | sed 's/\.gpg$//')")"
    wtype -M ctrl -k v -m ctrl

    echo "$(date +"%H:%M @ %S.%3N") - finish pass_type()" >> ~/dl/pw.log
}

wkey() {
    wtype -P "$1" -p "$1"
}
