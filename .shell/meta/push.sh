#!/usr/bin/env bash
# Use to push so I can have my pre-push hook.
# compress using tar so we can upload via FTP to jake.teton-landis.org

# Paths
REPO="git://github.com/justjake/Dotfiles.git"
TARBALL="https://github.com/justjake/Dotfiles/tarball/master"
DIRNAME=".dotfiles"

LOCAL="$HOME/$DIRNAME"
SERVER="ftp.teton-landis.org"
REMOTE="public_html/jake/repo/dotfiles"

curlGetHeaders="--header \"User-Agent: NOT CURL I PROMISE\""

# include hidden files
shopt -s nullglob
shopt -s dotglob


function push {
	echo "== running git push"
	cd $LOCAL
	git push
	echo "= push finished"
}

function makeTarball {
	echo "== Building Tarball"
	tarOptions="-cj --exclude '.git' --exclude '.gitignore' --exclude '.git'"
	cd $LOCAL
	tar $tarOptions * > $1
}

function upload {
	echo "== uploading tarball to $1"
	curlArgs="--user jake@teton-landis.org --upload-file $1"
	curl $curlArgs ftp://$SERVER/$REMOTE/$1
	echo "= upload complete"
}

echo "=== Push.sh"
makeTarball master.tar.gz
upload master.tar.gz
rm master.tar.gz
push
exit 0