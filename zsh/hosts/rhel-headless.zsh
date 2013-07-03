# Base config for all Rescomp hosts

# Tools config
export PREFIX="$HOME/prefixes/rhel-headless"

# Go nuts!
export GOROOT="$PREFIX/go"
export GOPATH="$PREFIX/gopath"
PATH="$GOROOT/bin:$GOPATH/bin:$PATH"

# rubygems! again!
export GEM_HOME="$PREFIX/rubygems"
PATH="$GEM_HOME/bin:$PATH"

export PATH
