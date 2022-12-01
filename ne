#!/bin/sh
# ne - norg export
# export .norg files to several formats

# {{{ reused colors/formatting
b="$(tput bold)"
sgr0="$(tput sgr0)"

f1="$(tput setaf 1)"
f6b="${b}$(tput setaf 6)"
# }}}

# {{{ input handling
# {{{ usage
usage() {
    cat <<EOF
${f6b}usage:${sgr0} ${0##*/} [FILE] [SWITCHES/OPTIONS]

${f6b}switches:${sgr0}

  -h, --help      show this message

  -d, --debug     debug mode
                  (show more output,
                  skip cleanup)

  -f, --formal    ${b}[pdf target only]${sgr0} formal mode
                  (set default font size to 12pt and
                  use an alternate preamble file)

${f6b}options:${sgr0}

  -c [XCOLOR], --linkcolor [XCOLOR]    ${b}[pdf target only]${sgr0} provide a link color
                                       (must be a color name compatible
                                       with ${b}xcolor${sgr0} LaTeX package)

  -n [NAMES],  --names     [NAMES]     ${b}[formal mode only]${sgr0} provide a list of names to include in the header
                                       [default: none]

  -p [PATH],   --preamble  [PATH]      provide a path to a LaTeX preamble or the word 'NONE'

  -l [PATH],   --filter    [PATH]      provide a path to a pandoc Lua filter or the word 'NONE'

  -t [FORMAT], --target    [FORMAT]    provide a file output format
                                       (must be a valid pandoc format)
                                       [default: pdf]

if you wish to change the default switches/options, edit lines 66 to 74 as well as 98 in this script's source code
-f, -c, -p and -l have hardcoded defaults that won't work for all users, you should probably change the defaults

by ${f6b}apeiros${sgr0}
EOF

    exit $1
}

[ $1 ] && [ $1 = '-h' -o $1 = '--help' ] && usage 0
# }}}

# {{{ get input file
[ ! $1    ] && echo -e "${f1}no file provided\n"             && usage 1 # no file
[ ! -f $1 ] && echo -e "${f1}provided file does not exist\n" && usage 1 # nonexistent file

origfile=$1                                        # original file
file="$(realpath "$origfile" | sed 's/\.norg$//')" # path without ext
shift
# }}}

# {{{ other option handling
# switches
debug=false  # debug mode?
formal=false # formal mode?

# opts
names=""                                  # last names (applicable only for formal mode)
linkcolor="linkblue"                      # link color
preamble="$HOME/org/.util/preamble.tex"   # path to a LaTeX preamble
filter="$HOME/org/.util/pagebreak.lua"    # path to a pandoc Lua filter
to="pdf"                                  # output format

# loop through remaining args
while [ $# -gt 0 ]; do
    case "$1" in
        # switches
        -h|--help     ) usage 0                    ;;
        -d|--debug    ) debug=true                 ;;
        -f|--formal   ) formal=true                ;;

        # opts
        -n|--names    ) names="$2"    ; shift      ;;
        -c|--linkcolor) linkcolor="$2"; shift      ;;
        -p|--preamble ) preamble="$2" ; shift      ;;
        -l|--filter   ) filter="$2"   ; shift      ;;
        -t|--target   ) to="$2"       ; shift      ;;

        # other
        --*           ) echo "bad option $1"       ;;
        *             ) echo "unknown argument $1" ;;
    esac
    shift
done

$formal && preamble="$HOME/org/.util/mla_preamble.tex"
# }}}

# {{{ check if converting to pdf
pdf=false
[ "$to" = "pdf" ] && {
    to="latex"
    pdf=true
}
# }}}
# }}}

# {{{ norg -> markdown
# hopefully one day there will be a better way to do this
# or there will be a way to use norg with pandoc directly
echo "converting ${f6b}norg${sgr0} to ${f6b}markdown$(tput sgr0)..."

# run exporter in nvim
nvim --headless +"Neorg export to-file $file.md" "$file.norg" > /tmp/neorg_export_out 2>&1 &

# get the pid
pid=$!
$debug && echo "pid: $pid"
$debug && {
    tail -F /tmp/neorg_export_out &
    tail=$!
}

# kill nvim if exited
trap "kill -KILL $pid" EXIT && $debug && echo "trap set"

# continuously attempt to kill nvim while it's still running
while ps cax | grep -Fq "$pid"; do
    # if file exists and successful export message was caught,                         kill nvim process
    [ -f "$file.md" ] && grep -Fqm1 "Successfully exported" "/tmp/neorg_export_out" && kill -KILL $pid && \
        $debug && kill -KILL $tail && echo -e "\nexporter killed"
done

# disable trap
trap - EXIT && $debug && echo "trap removed"

# if desired type is markdown, exit now
[ "$to" = "md" -o "$to" = "markdown" ] && exit 0
# }}}

# {{{ markdown -> new type
# {{{ markdown tweaks
# fix page breaks and line breaks (broken by neorg exporter)
sed -i 's/^pagebreak$/\\pagebreak/g' "$file.md"
sed -i 's/^lb$/\\texttt{}/g'         "$file.md"
sed -i 's/^\\$/\\texttt{}/g'         "$file.md"

# turn pending checkboxes into undone ones
sed -i 's/^\(\s*\-*\) \[\*\]/\1 \[ \]/g' "$file.md"
# }}}

# {{{ conversion step 1
echo "converting ${f6b}markdown${sgr0} to ${f6b}$to$(tput sgr0)..."

if [ "$filter" = 'NONE' ]; then
    if [ "$preamble" = 'NONE' ]; then
        pandoc --standalone -f markdown "$file.md" -t "$to" -o "$file.$to"
    else
        pandoc -H "$preamble" -f markdown "$file.md" -t "$to" -o "$file.$to"
    fi
else
    if [ "$preamble" = 'NONE' ]; then
        pandoc -L "$filter" --standalone -f markdown "$file.md" -t "$to" -o "$file.$to"
    else
        pandoc -L "$filter" -H "$preamble" -f markdown "$file.md" -t "$to" -o "$file.$to"
    fi
fi

[ $? -eq 0 ] && $debug && echo "successfully converted"
# }}}

# {{{ latex tweaks + conversion step 2 (pdf only)
$pdf && {
    echo "converting ${f6b}latex${sgr0} to ${f6b}pdf$(tput sgr0)..."

    # {{{ latex tweaks
    # nicer-looking checked off bullets
    sed -i 's/\\item\[\$\\boxtimes\$\]/\\item\[\\rlap{\\raisebox{0\.3ex}{\\hspace{0\.4ex}\\tiny \\ding{52} } }\$\\square\$\]/g' "$file.latex"

    # hack for colored links
    sed -i 's/\\hypersetup{/&colorlinks=true,linkcolor=linkblue,urlcolor=linkblue,/' "$file.latex"
    sed -i '0,/^  hidelinks,$/{/^  hidelinks,$/d;}' "$file.latex"

    # if formal, 12 pt
    $formal && sed -i 's/^\\documentclass\[$/&12pt/' "$file.latex"

    # if formal and has names opt
    $formal && [ "$names" ] && sed -i 's/^\\rhead{.*}$/\\rhead{'"$names"' \\thepage}/' "$file.latex"
    # }}}

    # {{{ lualatex
    # don't suppress output if debug -- suppress output if not debug mode
    $debug && lualatex "$file.latex" || lualatex "$file.latex" > /dev/null
    [ $? -eq 0 ] && $debug && echo "successfully converted"
    # }}}
}
# }}}
# }}}

# {{{ cleanup
# remove markdown file if not in debug mode
! $debug && {
    echo "removing ${f6b}markdown${sgr0} file..."
    rm "$file.md" 2> /dev/null
}

# remove latex files if not in debug mode
! $debug && $pdf && {
    echo "removing ${f6b}latex${sgr0} files and logs..."
    rm "$file.latex" "$file.aux" "$file.log" "texput.log" 2> /dev/null
} || true # exit cleanly
# }}}
