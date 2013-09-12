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

# where the dotfiles git repo is checked out to
DOTFILES_DIR="$HOME/.dotfiles"
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
janus
vimrc.after
gvimrc.after
)

# hide command output
alias -g no-output=">/dev/null 2>&1"

# ssh
function ssh-config () {
    mkdir -p "$HOME/.ssh/"
    ln -s "$DOTFILES_DIR/ssh_config" "$HOME/.ssh/config"
    chmod 0600 "$DOTIFLES_DIR/ssh_config"
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
    for file in "$desktop_config_dir"/* ; do
        if [ ! -f "$HOME/.config/${file}" ]; then
            echo "Linked .dotfiles/config/${file} -> ~/.config/${file}"
            ln -s ".dotfiles/config/${file}" ".config/${file}"
        else
            echo "skipped because file exists: ~/.config/${file}"
        fi
    done
    popd
}

# link basic files
function dotfiles () {
    pushd "$HOME" no-output
    for file in "${DOTFILES[@]}"; do
        if [ ! -f "$HOME/${file}" ]; then
            echo "Linked .dotfiles/${file} -> ~/${file}"
            ln -s ".dotfiles/${file}" ".${file}"
        else
            echo "skipped because file exists: ~/${file}"
        fi
    done
    popd no-output
}

# make sure we param ok?
if [ -z "$*" ]; then 
    echo "$0 - error.
Usage:
~/.dotfiles/meta/install.sh [MODULES...]
where 'extras' is any installation function defined here:
  - dotfiles:       the base dotfiles
  - submodules:     get all git submodules
  - ssh-config:     link my ssh-config into ~/.ssh/config
  - desktop-config: links in XDG_DESKTOP settings in ~/.config"
    exit 1
fi

# and whatever else the user requests
for cmd in "$@"; do
    $cmd
done
