#!/usr/bin/env bash
# Download and extract dotfiles

nogit() {
    # Determine extractor capability
    TYPE="tarball" && UNPACK="tar -zxf" && PACKAGE="jark_dotfiles.tar.gz"
    # which unzip &> /dev/null && TYPE="zipball" && UNPACK="unzip" && PACKAGE="jark_dotfiles.zip"

    REMOTE_LOCATION="https://github.com/justjake/Dotfiles/$TYPE/new"

    which curl > /dev/null && GET="curl -Ls $REMOTE_LOCATION"
    which wget > /dev/null && GET="wget -q -O - $REMOTE_LOCATION"

    [ -z "$GET" ] && echo "Requires curl or wget to fetch package file"

    $GET > /tmp/$PACKAGE
    cd /tmp
    $UNPACK /tmp/$PACKAGE
    mv /tmp/justjake-Dotfiles* $HOME/.dotfiles
}

hasgit() {
    git clone "https://justjake@github.com/justjake/Dotfiles.git" "$HOME/.dotfiles"
    cd "$HOME/.dotfiles"
    git checkout new
}

METHOD="nogit"
which git > /dev/null && METHOD="hasgit"

echo $METHOD

# only execute if .dotfiles doesn't exist
[ -a "$HOME/.dotfiles" ] && echo "~/.dotfiles already exists; aborting" && exit 1

# Run bootstrap
$METHOD

# hand install over to install.sh
/usr/bin/bash $HOME/.dotfiles/jark/install.sh
