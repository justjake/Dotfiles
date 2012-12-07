#!/usr/bin/env zsh

DOTFILE_MODULES="$DOTFILES/modules"

# ZSH Functions
function fractal {
   local lines columns colour a b p q i pnew
   ((columns=COLUMNS-1, lines=LINES-1, colour=0))
   for ((b=-1.5; b<=1.5; b+=3.0/lines)) do
       for ((a=-2.0; a<=1; a+=3.0/columns)) do
           for ((p=0.0, q=0.0, i=0; p*p+q*q < 4 && i < 32; i++)) do
               ((pnew=p*p-q*q+a, q=2*p*q+b, p=pnew))
           done
           ((colour=(i/4)%8))
            echo -n "\\e[4${colour}m "
        done
        echo
    done
    echo -n "\e[49m"
}

function this_script_dir {
    echo "$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
}

function link-dotfile-module {
    BUNDLE_DIR="$DOTFILE_MODULES/$1"
    echo installing $BUNDLE_DIR
    TARGET_LOC="$(expand-string "$(cat "$BUNDLE_DIR/.target")")"
    cd $HOME
    ln -s -v "$BUNDLE_DIR" "$TARGET_LOC"
}

function expand-string {
    eval echo "$1"
}
