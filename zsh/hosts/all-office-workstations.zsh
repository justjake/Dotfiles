# include RHEL stuff
add-bundle-to-path "$HOME/prefixes/rhel-headless/bundles/vim"

# deal with Gnome Terminal being silly
if [[ $COLORTERM == "gnome-terminal" ]] ; then
    export TERM="xterm-256color"
fi

# Include standard prefix
export PREFIX="$HOME/prefixes/workstation"
# add-bundle-to-path "$PREFIX/derp" #glibc 2
bundle-dir "$PREFIX/bundles"
add-bundle-to-path "$PREFIX"

# Go
export GOROOT="$PREFIX/go"
export GOPATH="$PREFIX/gopath"
export PATH="$GOROOT/bin:$GOPATH/bin:$PATH"

# Plan9 from User Space
PLAN9="$PREFIX/usr/local/plan9port"
export PLAN9
PATH="$PATH:$PLAN9/bin"
export PATH

# Java
export JAVA_HOME="$PREFIX/bundles/jdk1.7.0_51"

# Aliases
alias tbird="thunderbird & disown"
alias open="gnome-open"
alias dev-mount="sshfs dev-www9.rescomp.berkeley.edu:/usr/code/jitl $HOME/mnt/devbox"
alias dev-unmount="fusermount -u $HOME/mnt/devbox"

develop () {
    dev-mount
    idea.sh & disown
}


APP_NOTES="$HOME/applications_spring_2014"

rev-app () {
    local name="$(basename "$1")"
    local dest="$APP_NOTES/$name.md"
    for appdir in "/export/teams/programmers/applicants/$name"* ; do
        cp "$appdir/info.txt" "$dest"
        for file in "$appdir"/* ; do
            [[ "$(basename $file)" != info.txt ]] && gnome-open "$file"
        done
        echo -e "\n\ncomments:" >> "$dest"
        $EDITOR "$dest"
    done
}
