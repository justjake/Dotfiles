#!/usr/bin/env sh
# Install dotfiles from ~/.dotfiles into $HOME
# inspired by https://github.com/joshuaclayton/dotfiles/blob/master/Rakefile, but rewritten in
# plain shell script because who knows if `hostname` has rake?

symlink () { # $1 -> target, $2 -> linklocation
    [ -h "$2" ] && rm "$2"
    [ -a "$2" ] && echo "Error: file exists: $2" && exit 1
    echo "Symlinking $2 -> $1"
    ln -s "$1" "$2"
}

target_path () { # $1 -> filename
    echo ".$1"
}

install () {
    echo "Installing"
    cd "$HOME"
    for dotfile in .dotfiles/*; do
        symlink ".dotfiles/$dotfile" "`target_path $dotfile`"
    done
}

postinstall () {
    which git > /dev/null
    if [ -eq "$?" "0" ] ; then
        postinstall_git
    else
        postinstall_nogit
    fi
    which rake > /dev/null
    if [ -eq "$?" "0" ] ; then
        postintall_rake
    else
        postinstall_norake
    fi
}

postinstall_git() {
    cd "$HOME/.dotfiles"
    git submodule update --init --recursive
}

postinstall_nogit () {
    echo "Git free system. Assuming submodules handled by github"
}

postinstall_rake () {
    cd "$HOME/.vim"
    rake
}

postinstall_norake () {
    # Damn, we can't use Janus because Janus needs rake
    # oh well, we just use the old .vimrc stuff I guess
    cd "$HOME"
    symlink ".dotfiles/.vim.nojanus" ".vim"
    symlink ".dotfiles/.vimrc.nojanus" ".vimrc"
}

install
