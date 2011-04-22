#!/usr/bin/env bash
# Update dotfiles from repo

REPO="git://github.com/justjake/Dotfiles.git"
TARBALL="https://github.com/justjake/Dotfiles/tarball/master"
DIRNAME=".dotfiles"
LOCAL="$HOME/$DIRNAME"

oldpwd="$PWD"

#test for git
if [ ! -z "$(which git)" ]; then
	USEGIT="true"
else
	USEGIT=""
fi


function updateDots {
	if [ ! -z "$USEGIT" ]; then
		# just run git update
		cd "$LOCAL"
		git pull
	else
		cd "$LOCAL"
		wget --no-check-certificate "$TARBALL"
		tar -zxf justjake-Dotfiles-*.tar.gz
		rm justjake-Dotfiles-*.tar.gz
		mv justjake-Dotfiles-* UpdateSource
		cd UpdateSource
		
		shopt -s nullglob
		shopt -s dotglob # To include hidden files
		for file in $(find * -type f)
		do
			rm ../"$file"
			mv $file ../
		done
	fi
}

function downloadDots {
	if [ ! -z "$USEGIT" ]; then
		git clone "https://justjake@github.com/justjake/Dotfiles.git" "$LOCAL"
	else
		mkdir "$LOCAL"
		cd "$LOCAL"
		wget -O tarball.tar.gz --no-check-certificate "$TARBALL"
		tar -zxf tarball.tar.gz
		rm tarball.tar.gz
		mv * new
		mv new/* ./
		rm -r new
	fi
}



# check if this dir exists and has files
if [ -d "$LOCAL" ]; then
	shopt -s nullglob
	shopt -s dotglob # To include hidden files
	files=($LOCAL/*)
	if [ ${#files[@]} -gt 0 ]; then
		## DO UPDATE
		updateDots
	else
		# no files in dir
		downloadDots
	fi
else
	downloadDots
fi

# link all
cd "$LOCAL"
echo Trying to link files
shopt -s nullglob
shopt -s dotglob # To include hidden files
for file in *
do
	cd $HOME
	echo "Linking $file"
	
	ln -s "$DIRNAME"/"$file" "$file"
	cd "$LOCAL"
done