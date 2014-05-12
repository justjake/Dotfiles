#!/bin/bash

set -e

help () {
    echo "$0 - bundleinstall-tmux"
    echo "Usage: $0 BUNDLE_PATH"
    echo " eg,   $0 ~/bundles/tmux-1.8"
    cat <<HELP
This script compiles and installs 'tmux' (and its dependencies libevent
and ncurses) into the specified bundle prefix path. If the prefix path
does not exist, it is created.

It evolved initially from the install script gist at
https://gist.github.com/ryin/3106801
HELP
}

mk_libevent () {
    cd "$bundle_tmp"

    ############
    # libevent #
    ############
    tar xvzf libevent.tar.gz
    cd libevent*
    ./configure --prefix="$bundle" --disable-shared
    make
    make install
}

mk_ncurses () {
    cd "$bundle_tmp"

    ############
    # ncurses #
    ############
    tar xvzf ncurses.tar.gz
    cd ncurses*
    ./configure --prefix="$bundle"
    make
    make install
}

mk_tmux () {
    cd "$bundle_tmp"

    ############
    # tmux #
    ############
    tar xvzf tmux.tar.gz
    cd tmux*
    ./configure --prefix="$bundle" CFLAGS="-I$bundle/include -I$bundle/include/ncurses" LDFLAGS="-L$bundle/lib -L$bundle/include/ncurses -L$bundle/include"
    CPPFLAGS="-I$bundle/include -I$bundle/include/ncurses" LDFLAGS="-static -L$bundle/include -L$bundle/include/ncurses -L$bundle/lib" make
    make install
}





main () {
    bundle="$1"
    bundle_tmp="$bundle/tmp"

    if [[ -z "$bundle" ]] ; then
        echo -e "Error: no bundle path provided.\n"
        help
        exit 2
    fi

    mkdir -p "$bundle_tmp"
    cd "$bundle_tmp"

    # download source files for tmux, libevent, and ncurses
    wget -O tmux.tar.gz http://downloads.sourceforge.net/project/tmux/tmux/tmux-1.8/tmux-1.8.tar.gz
    wget -O libevent.tar.gz https://github.com/downloads/libevent/libevent/libevent-2.0.21-stable.tar.gz
    wget -O ncurses.tar.gz ftp://ftp.gnu.org/gnu/ncurses/ncurses-5.9.tar.gz

    # extract files, configure, and compile
    mk_libevent
    mk_ncurses
    mk_tmux

    # clean up
    rm -rf "$bundle_tmp"
}

main "$1"
