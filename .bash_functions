#!/bin/bash
# ~/.bash_functions
# author: starise

# Extract script
# Auto-detect proper command to extract an archive.
function extract() {
    if [ -f $1 ] ; then
        case $1 in
            *.tar.bz2)  tar xvjf $1;;
            *.tar.gz)   tar xvzf $1;;
            *.bz2)      bunzip2 $1;;
            *.rar)      unrar x $1;;
            *.gz)       gunzip $1;;
            *.tar)      tar xvf $1;;
            *.tbz2)     tar xvjf $1;;
            *.tgz)      tar xvzf $1;;
            *.zip)      unzip $1;;
            *.Z)        uncompress $1;;
            *.7z)       7z x $1;;
            *)          echo "don't know how to extract '$1'...";;
        esac
    else
        echo "'$1' is not a valid file!"
    fi
}

# Repeat N times a command
function repeat() {
    local i max
    max=$1; shift;
    for ((i=1; i <= max ; i++)); do  # --> C-like syntax
        eval "$@";
    done
}

# Up N directories
# Example: up 3 <=> cd ../../../
function up(){
    local d=""
    limit=$1
    for ((i=1 ; i <= limit ; i++))
    do
        d=$d/..
    done
    d=$(echo $d | sed 's/^\///')
    if [ -z "$d" ]; then
        d=..
    fi
    cd $d
}


# Simple note taker
# https://wiki.archlinux.org/index.php/Bashrc
function note() {
    # if file doesn't exist, create it
    if [[ ! -f $HOME/.notes ]]; then
        touch "$HOME/.notes"
    fi

    if ! (($#)); then
        # no arguments, print file
        cat "$HOME/.notes"
    elif [[ "$1" == "-c" ]]; then
        # clear file
        > "$HOME/.notes"
    else
        # add all arguments to file
        printf "%s\n" "$*" >> "$HOME/.notes"
    fi
}

# Simple task utility
# https://wiki.archlinux.org/index.php/Bashrc#Simple_note_taker
function todo() {
    if [[ ! -f $HOME/.todo ]]; then
        touch "$HOME/.todo"
    fi

    if ! (($#)); then
        cat "$HOME/.todo"
    elif [[ "$1" == "-l" ]]; then
        nl -b a "$HOME/.todo"
    elif [[ "$1" == "-c" ]]; then
        > $HOME/.todo
    elif [[ "$1" == "-r" ]]; then
        nl -b a "$HOME/.todo"
        eval printf %.0s- '{1..'"${COLUMNS:-$(tput cols)}"\}; echo
        read -p "Type a number to remove: " number
        sed -i ${number}d $HOME/.todo "$HOME/.todo"
    else
        printf "%s\n" "$*" >> "$HOME/.todo"
    fi
}

# Simple command line calculator
# Example: calc 2+2
function calc() {
    echo "scale=3;$@" | bc -l
}
