#!/usr/bin/env bash

gpgfile="$(find "$HOME/.pass" | grep 'user\.gpg$' | head -n 1)"

if [ -n "$gpgfile" ]; then
    echo "unlock gpg key for pass"
    gpg --pinentry-mode loopback --quiet -d "$gpgfile"
fi

echo lol > /tmp/gpgpass
hyprctl dispatch killactive
exit
