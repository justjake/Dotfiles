# FreeBSD devbox config

export PREFIX="$HOME/prefixes/freebsd"
export PATH="$PATH:$PREFIX/bin"

# virtualenv
export WORKON_HOME="$PREFIX/virtualenvs"
mkdir -p "$WORKON_HOME"
source "$(which virtualenvwrapper.sh)"

# bug-tool
workon bugtool
source "$(which bug-helper.sh)"
