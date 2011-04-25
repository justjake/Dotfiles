#!/usr/bin/env bash
# Update dotfiles from repo

REPO="git://github.com/justjake/Dotfiles.git"
TARBALL="https://github.com/justjake/Dotfiles/tarball/master"
DIRNAME=".dotfiles"
LOCAL="$HOME/$DIRNAME"

# include hidden files
shopt -s nullglob
shopt -s dotglob

#test for git
if [ ! -z "$(which git)" ]; then
	USEGIT="true"
else
	USEGIT=""
fi

# @TODO
# use newest update.sh

cd "$HOME"

echo "==== Dotfiles Updater"
echo "= grab the newest updater by"
echo "curl -fsSL https://github.com/justjake/Dotfiles/raw/master/.shell/update.sh | bash"

function downloadTarball {
	curl -fsSL $1 | tar -zxf - -C $2
	mv justjake-Dotfiles-* $2
}

function updateDots {
    echo "== $DIRNAME found, updating Dotfiles"
	if [ ! -z "$USEGIT" ]; then
		# just run git update
		echo "Updating via git pull"
		echo "If git pull throws errors, please update manually"
		cd "$LOCAL"
		git pull
	else
	    echo "updating via tarball at $TARBALL"
		cd "$LOCAL"
		downloadTarball "$TARBALL" UpdateSource
		cd UpdateSource
		shopt -s nullglob
		shopt -s dotglob # To include hidden files
		for file in $(find * -type f)
		do
			rm ../"$file"
			mv $file ../"$file"
		done
		rm -r UpdateSource
	fi
	echo "= Update complete"
}

function downloadDots {
	echo "== No $DIRNAME found, new Dotfiles installation"
	if [ ! -z "$USEGIT" ]; then
	    echo "Downloading via git clone"
		git clone "https://justjake@github.com/justjake/Dotfiles.git" "$LOCAL"
		echo "Remember to 'git remote rm origin; git remote add git@github.com:justjake/Dotfiles.git' to make changes"
	else
		mkdir "$LOCAL"; cd "$LOCAL"
	    echo "Downloading via tarball at $TARBALL"
		downloadTarball "$TARBALL" UpdateSource
		mv UpdateSource/* ./

		rm -r UpdateSource
	fi
	echo "= Download complete."
}

function handleFile {
	if [[ -a "$HOME/$1" ]]; then
		echo "$1 exists; skipping."
	else
		echo "Linking $1 -> $LOCAL/$1"
		ln -s "$LOCAL"/"$1" "$HOME/$1"
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
echo "== Linking files"
shopt -s nullglob
shopt -s dotglob # To include hidden files
for file in *
do
	cd "$HOME"

	case "$file" in
		".git")
			echo "skipping $file - part of version control"
			;;
		".gitignore")
			echo "skipping $file - part of version control"
			;;
		"README")
			echo "skipping $file - part of version control"
			;;
		*)
			# copy the file
			handleFile "$file"
			;;
		esac

	cd "$LOCAL"
done
echo "=== update complete"

