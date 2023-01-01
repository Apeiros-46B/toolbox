#!/bin/sh
# xc - xclip
# simplify pasting files with xclip

[ ! "$1"  ] && echo 'usage: <file> [type]'    && exit 1
[ -e "$1" ] && echo 'destination file exists' && exit 1

if [ "$2" ]; then
    xclip -o -selection clipboard -t "$2" > "$1"
else
    xclip -o -selection clipboard         > "$1"
fi
