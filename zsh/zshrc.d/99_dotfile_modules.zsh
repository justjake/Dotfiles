# I haven't used any of these in an eon. They should be reviewed
# and removed in favor of meta/install.sh

#### dotfile modules
# folders that go someplace other than ~/ that have settings
DOTFILE_MODULES="$DOTFILES/modules"

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
