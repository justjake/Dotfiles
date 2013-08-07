#!/usr/bin/env zsh
DOTFILE_MODULES="$DOTFILES/modules"

# ZSH Functions
alias -g no-output=">/dev/null 2>&1"

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


#### setup stuff
# a bundle is a UNIX prefix
# this prepends the bundle's directories to your various tool
# load paths, so they take precedence over system versions

function add-bundle-to-path {
    local bundle="$1"
    [[ -d "$bundle/bin" ]] && export PATH="$bundle/bin:$PATH"
    [[ -d "$bundle/share/man" ]] && export MANPATH="$bundle/share/man:$MANPATH"
    [[ -d "$bundle/lib" ]] && export LD_LIBRARY_PATH="$bundle/lib:$LD_LIBRARY_PATH"
    [[ -d "$bundle/lib64" ]] && export LD_LIBRARY_PATH="$bundle/lib64:$LD_LIBRARY_PATH"
    [[ -d "$bundle/lib/pkgconfig" ]] && export PKG_CONFIG_PATH="$bundle/lib/pkgconfig"

    # add sub folders like "usr"
    [[ -d "$bundle/usr" ]] && add-bundle-to-path "$bundle/usr"
}

# svn

# merge a python package to release
function svn-merge-to-release {
    # params
    local pkg="$1"
    local rmt="https://svn.rescomp.berkeley.edu/marketing/python/branches/STABLE/$pkg"

    # local vars
    local my_local_path="/usr/code/$USER/marketing/python/branches"

    # get logs from stable
    svn log -l 5 "$rmt"

    # read in rev number
    echo "which rev number for a -c merge?"
    echo -n "R: "
    read rev

    pushd "$my_local_path/RELEASE/$pkg"
    # dry merge
    svn merge --dry-run -c "$rev" "$rmt" .

    # wet merge ... we wait at the user password field the second time
    svn merge -c "$rev" "$rmt" .

    popd
}




#### Utilities

function command-exists {
    command -v "$1" no-output
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
    
#### Configurators

### install system tools things
setup-go-with-vim () {
    if [ -n "$GOROOT" ] ; then
        # basic scripts
        echo "linking VIM integration from $GOROOT/misc/vim into ~/.janus"
        [ ! -e "$HOME/.janus/go-tools" ] && ln -s "$GOROOT/misc/vim" "$HOME/.janus/go-tools"

        # autocomplete
        echo "Installing gocode for autocomplete"
        go get -u github.com/nsf/gocode
        [ ! -e "$HOME/.janus/gocode" ] && ln -s "$GOROOT/src/pkg/github.com/nsf/gocode/vim" "$HOME/.janus/gocode"
    else
        echo "GOROOT is unset, cannot link vim tools"
    fi
}

# use office client setup for the current host
use-office-client () {
    pushd "$ZSH_FILES/hosts/" no-output
    ln -s "all-office-workstations.zsh" "`hostname`.zsh"
    popd no-output
}
