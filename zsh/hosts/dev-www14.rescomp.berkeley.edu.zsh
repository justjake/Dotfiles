export CODE="/usr/code/jitl"
export OLD_HOME="/usr/home/jitl"
# Python devbox
export WORKON_HOME="$CODE/virtualenvs"
source $(which virtualenvwrapper.sh)

# Golang
export GOROOT="$OLD_HOME/go"
export GOPATH="$OLD_HOME/gopath"
export PATH="$PATH:$GOROOT/bin:$GOPATH/bin"
eval "$(go env)"

# personal preference
# PROJECT="$HOME/gopath/src/github.com/justjake/mail"
PROJECT="$CODE"

### Prefix!
PREFIX="$OLD_HOME/prefix"
bundle-dir "$PREFIX/bundles"
# bin stuff - front of path
export PATH="$PREFIX/bin:$PATH"
# lib stuff
export LD_LIBRARY_PATH="$LD_LIBRARY_PATH:$PREFIX/lib"
export PKG_CONFIG_PATH="$PREFIX/lib/pkgconfig"
# rubygems
# export GEM_HOME="$PREFIX/rubygems"
# PATH="$GEM_HOME/bin:$PATH"

### rbenv
export RBENV_ROOT="$OLD_HOME/prefixes/rhel-headless/rbenv"
export PATH="$RBENV_ROOT/bin:$PATH"
eval "$(rbenv init -)"

which bug-helper.sh no-output && source "$(which bug-helper.sh)"

bundle-dir "$OLD_HOME/bundles"
