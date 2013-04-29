#!/usr/bin/env zsh
DOTFILES_DIR="$HOME/.dotfiles"
cd "$DOTFILES_DIR"

# pull git submodules
if [[ $1 -eq "-r" ]] ; then
    git submodule update --init --recursive
fi

# link basic files
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

cd "$HOME"
for file in "${DOTFILES[@]}"; do
    if [ ! -f "$HOME/${file}" ]; then
        ln -s ".dotfiles/${file}" ".${file}"
        echo "Linked .dotfiles/${file} -> ~/${file}"
    else
        echo "skipped because file exists: ~/${file}"
    fi
done
