#!/bin/sh

# Usage: statify-pc.sh [-bp] PCFILE...
# Modify pkg-config PCFILE... for static linking.
# if PCFILE is missing or -, read stdin (implies -p, ignores -b)
#    -b  Backup each PCFILE to PCFILE.bak first.
#    -p  Print the modified content without writing/backing files.
#
# modify pkg-config files PCFILE... for static linking with these libs even
# if the packages deps are retrieved using pkg-config without --static,
# by adding the private Libs/Requires values to the respective non-private
# lines, and then deleting the private lines.

echo() { printf %s\\n "$*"; }

#1 $1: pc file content,  $2: NAME (trimmed) content to get
pcget() {
    echo "$1" | while IFS= read -r line; do
        case $line in *"$2:"*) vals=${line#*"$2:"}; echo $vals; esac
    done
}

# stdin: pc file content,  $1: NAME,  $2:separator,  $3: stuff to add
# if "NAME:" was not found, add a line of "NAME: values"
pcappend() {
    [ "$3" ] || { cat; return; }
    found=
    while IFS= read -r line; do
        case $line in *"$1:"*)
            # add the separator if it's not space and the line has content
            [ "$2" = " " ] || [ -z "$(echo ${line#*"$1:"})" ] || line="$line$2"
            line="$line $3" found=yes
        esac
        echo "$line"
    done
    [ "$found" ] || echo "$1: $3"
}

# stdin: pc file content,  $1: NAME line to remove if found
pcremove() {
    while IFS= read -r line; do
        case $line in *"$1:"*) ;; *) echo "$line"; esac
    done
}


bak= printonly=
while getopts bp o; do
    case $o in
        b) bak=yes ;;
        p) printonly=yes ;;
    esac
done
shift $((OPTIND-1))
[ "$#" -gt 0 ] || set -- -

for fname; do
    { [ "$printonly" ] || [ "$fname" = - ]; } && p=x || p=

    [ "$p" ] || [ -z "$bak" ] || cp -p "$fname" "$fname.bak"
    src=$(cat -- "$fname")  # '-' is stdin for cat
    out=$(  echo "$src" \
            | pcappend Requires ","  "$(pcget "$src" Requires.private)" \
            | pcappend Libs     " "  "$(pcget "$src" Libs.private)" \
            | pcremove Requires.private \
            | pcremove Libs.private  )
    if [ "$p" ]; then echo "$out"; else echo "$out" > "$fname"; fi
done

