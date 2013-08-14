# Include standard prefix
PREFIX="$HOME/prefixes/workstation"
# add-bundle-to-path "$PREFIX/derp" #glibc 2
# add-bundle-to-path "$PREFIX"

# Go
export GOROOT="$PREFIX/go"
export GOPATH="$PREFIX/gopath"
export PATH="$GOROOT/bin:$GOPATH/bin:$PATH"

# Plan9 from User Space
PLAN9="$PREFIX/usr/local/plan9port"
export PLAN9
PATH="$PATH:$PLAN9/bin"
export PATH

# Aliases
alias tbird="thunderbird & disown"
alias open="gnome-open"

# deal with Gnome Terminal being silly
if [[ $COLORTERM == "gnome-terminal" ]] ; then
    export TERM="xterm-256color"
fi
