#!/usr/bin/env bash

pw_dir="$(dirname "$0")"
arg="$1"
cd "$pw_dir"

# if help flag passed, print manpage and exit
[ "$arg" == "-h" ] || [ "$arg" == "--help" ] && cat "./README.md" && exit

if [ "$arg" == "-i" ] || [ "$arg" == "--interactive" ]; then
    interactive='true'
else
    interactive=''
fi

source ./functions.sh

pass_folder=""
key_sequence=""
while IFS= read -r line; do
	# class pattern must match either app type or the class string
	match="$(echo "$line" | awk -F "$mapsep" '{ print $1 }')"
	[ "$app" != "$match" ] && [ -z "$(echo "$class" | grep "$match")" ] && continue

	# the title pattern must match the title string
	match="$(echo "$line" | awk -F "$mapsep" '{ print $2 }')"
	[ -z "$(echo "$title" | grep "$match")" ] && continue

	# if we got here, both the class and title matched
	pass_folder="$(echo "$line" | awk -F "$mapsep" '{ print $3 }')"
	key_sequence="$(echo "$line" | awk -F "$mapsep" '{ print $4 }')"
	break
done <<< "$map"

if [ -z "$pass_folder" ]; then # we did not match, pass_folder is empty, need input
    pass_folder="$(ls "$pass_store" | $menu)"
elif [ -n "$interactive" ]; then # we did match, but interactive mode forces menu
    full_list="$(echo "$pass_folder" && echo " " && ls "$pass_store")"
    pass_folder="$(echo "$full_list" | $menu)"
fi
[ -z "$pass_folder" ] && exit # just an assert

# if key sequence is blank, let user choose it, then type and exit
if [ -z "$key_sequence" ] || [ -n "$interactive" ]; then
    pass_type
    exit
fi

# key sequence must be populated now. parse and print
for (( i=0; i<${#key_sequence}; i++ )); do
    char="${key_sequence:$i:1}"

    if [ -z "$(echo $char | sed '/[a-z]/d')" ]; then # lowercase
	pass_type "$char"
	continue
    fi

    case "$char" in
	'$') pass_type "$(hostname)" ;;
	'~') pass_type "$(whoami)" ;;
	'.') pass_type ;;

	'T') wkey Tab ;;
	'E') wkey Return ;;
	'R') wkey Return ;;
	' ') wtype ' ' ;;
    esac
done

cd "$original_dir"
