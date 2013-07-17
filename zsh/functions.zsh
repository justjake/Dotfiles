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

function use-office-workstation {
    cd "$ZSH_FILES/hosts"
    ln -s all-office-workstations.zsh $(hostname).zsh
    popd
}

#### setup stuff

# add all the bundles in a DIR to $PATH and $MANPATh
# a bundle is a directory that contains bin and man, and maybe lib

function add-bundle-to-path {
    local bundle
    bundle="$1"
    if [[ -d "$bundle/bin" ]]; then
        PATH="$bundle/bin:$PATH"
    else
        PATH="$bundle:$PATH"
    fi

    [[ -d "$bundle/share/man" ]] && MANPATH="$MANPATH:$bundle/share/man"
}

function bundle-dir {
    local BUNDLES="$1"
    local bundle
    if [[ -d "$BUNDLES" ]]; then
        for bundle in "$BUNDLES"/*; do
            add-bundle-to-path $bundle
        done
    else
        echo "$BUNDLES does not exist"
    fi
}

#### Utilities

function command-exists {
    command -v "$1" >/dev/null 2>&1
}

function this-script-dir {
    echo "$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
}

function expand-string {
    eval echo "$1"
}

#### dotfile modules 
# folders that go someplace other than ~/ that have settings

function dotfile-module-install {
    local BUNDLE_DIR
    BUNDLE_DIR="$DOTFILE_MODULES/$1"
    echo installing $BUNDLE_DIR
    TARGET_LOC="$(expand-string "$(cat "$BUNDLE_DIR/.target")")"
    cd $HOME
    ln -s -v "$BUNDLE_DIR" "$TARGET_LOC"
}

function dotfile-module-list {
    ls "$DOTFILE_MODULES"
}

function dotfile-module-show {
    if [[ ! -d "$DOTFILE_MODULES/$1" ]] ; then
        echo "Module $1 does not exist"
    else
        echo \
"Dotfile Module:
    $DOTFILE_MODULES/$1

Link Location:
    $(cat "$DOTFILE_MODULES/$1/.target")
    $(expand-string "$(cat "$DOTFILE_MODULES/$1/.target")")

Contents:"
        ls -al "$DOTFILE_MODULES/$1"
    fi
}
    

### install system tools things
setup-go-with-vim () {
    if [ -n "$GOROOT" ] ; then
        # basic scripts
        echo "linking VIM integration from $GOROOT/misc/vim into ~/.janus"
        [ ! -e "$HOME/.janus/go-tools" ] && ln -s "$GOROOT/misc/vim" "$HOME/.janus/go-tools"
    else
        echo "Goroot unset, cannot link go-tools"
    fi

    # autocomplete
    echo "Installing gocode for autocomplete"
    go get -u github.com/nsf/gocode
    [ ! -e "$HOME/.janus/gocode" ] && ln -s "$GOROOT/src/pkg/github.com/nsf/gocode/vim" "$HOME/.janus/gocode"
}
