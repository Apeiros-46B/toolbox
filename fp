#!/bin/sh
# fp - file picker
# pick files with fzf and open dragon-drop with them

usage() {
    echo 'usage: fp [location] [pattern to exclude] [previewer program]'
}

bgr() { # background runner function
    set +m                        # silence job control messages
    nohup "$@" > /dev/null 2>&1 & # silence output and make immune to hangups
    set -m                        # re-enable job control messages
}

# get location
location="./"
[ "$1" ] && location="$(realpath "$1")/" && shift

# escaped
escaped="$(echo "$location" | sed -e 's/\./\\./g' -e 's/\//\\\//g')"

# get exclude pattern
exclude_pattern="^$"
[ "$1" ] && exclude_pattern="$1" && shift

# get previewer program
preview="preview"
[ "$1" ] && preview="$(realpath "$1")" && shift

# main pipeline
#     find: list files and print unix time before them
#     sort: sort list in reverse order (recently modified first)
#     sed:  remove unix time and location from each line
#     grep: remove excluded patterns from list
#     fzf:  fuzzy find provided files
#               -m:     allow multi-select
#               --bind: bind Ctrl+O to preview program
#     awk:  re-add location to each selected file from fzf
#     bgr:  open target program with selected files

find "$location" -type f -printf '%T@ %p\n' 2> /dev/null            \
    | sort -r                                                       \
    | sed "s/^[0-9]*\\.[0-9]* $escaped//"                           \
    | grep -Ev -e "$exclude_pattern"                                \
    | fzf -m --bind "ctrl-o:execute-silent($preview '$location'{})" \
    | awk '{ print "'"$location"'" $0 }'                            \
    | bgr dragon-drop -x -a -T -I -s 64
