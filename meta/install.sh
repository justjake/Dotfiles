#!/usr/bin/env zsh
####
# Dotfiles/meta/install.sh
# simple script to link my dotfiles into $HOME
# @author Jake Teton-Landis <just.1.jake@gmail.com>
#
# Usage:
# ~/.dotfiles/meta/install.sh [EXTRAS...]
# where "extras" is any installation function defined here:
#   - dotfiles:       the base dotfiles
#   - submodules:     get all git submodules
#   - ssh-config:     link my ssh-config into ~/.ssh/config
#   - desktop-config: links in XDG_DESKTOP settings in ~/.config
####

set -e

# where the dotfiles git repo is checked out to
DOTFILES_DIR="$HOME/.dotfiles"
BUNDLES_DIR="$HOME/bundles"
# list of files to link into homedir
DOTFILES=(
zshrc
zsh

gitconfig
gitignore_global

hgrc

bin
tmux.conf
screenrc

vim
vimrc

tmux.conf
tmux

editrc
)

# hide command output
alias -g no-output=">/dev/null 2>&1"

# same semantics as ln -s
# creates a new symlink at $2 that points to $1
# if $2 exists, then it is backed up using mv
function link-into-place () {
    local src="$1"
    local dst="$2"

    if [[ -e "$dst" ]]; then
        # file exists, move it out of the way by timestamp
        local ts=$(date +%Y-%m-%d.%H:%M:%S)
        local backup="$dst.bak-${ts}"

        echo "target $dst: Moving existing file '$dst' to '$backup'"
        mv "$dst" "$backup"
    fi

    echo "target $dst: Linking '$src' --> '$dst'"
    ln -sv "$src" "$dst"
}

# ssh
function ssh-config () {
    mkdir -p "$HOME/.ssh/"
    link-into-place "$DOTFILES_DIR/ssh_config" "$HOME/.ssh/config"
    chmod 0600 "$DOTFILES_DIR/ssh_config"
}

# git
function submodules () {
    if which git no-output; then
        pushd "$DOTFILES_DIR" no-output
        git submodule update --init --recursive
        popd no-output
    else
        echo "Cannot get submodules -- git not found"
    fi
}

# desktop config
function desktop-config () {
    local desktop_config_dir="$HOME/.dotfiles/config"
    mkdir -p "$HOME/.config"

    pushd "$HOME" no-output
    for file_fullname in "$desktop_config_dir"/* ; do
	local file="$(basename "$file_fullname")"
        if [ ! -e "$HOME/.config/${file}" ]; then
            echo "Linked .dotfiles/config/${file} -> ~/.config/${file}"
            ln -s "$file_fullname" ".config/${file}"
        else
            echo "skipped because path exists: ~/.config/${file}"
        fi
    done
    popd
}



# link basic files
function dotfiles () {
    pushd "$HOME" no-output
    for file in "${DOTFILES[@]}"; do
        link-into-place ".dotfiles/${file}" ".${file}"
    done

    # bundles dir is defaulty sourced in zshrc.d/02_bundles.zsh
    mkdir -p -v "$BUNDLES_DIR"

    # link in node bundles on sytems with JS support
    link-into-place ".dotfiles/dotfiles-node" "$BUNDLES_DIR/"
    popd no-output
}

function js () {
}

function brew () {
    git clone "https://github.com/Homebrew/linuxbrew" "$BUNDLES_DIR/linuxbrew"
}

# make sure we param ok?
if [ -z "$*" ]; then
    echo "$0 - error.
Usage:
~/.dotfiles/meta/install.sh [MODULE...]
where 'MODULE' is any installation function defined here:
  - dotfiles:       the base dotfiles
  - submodules:     get all git submodules
  - ssh-config:     link my ssh-config into ~/.ssh/config
  - desktop-config: links in XDG_DESKTOP settings in ~/.config
  - brew:           install linuxhomebrew"
    exit 1
fi

# and whatever else the user requests
for cmd in "$@"; do
    $cmd
done
