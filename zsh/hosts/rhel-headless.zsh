# Base config for all Rescomp hosts

# Tools config
export PREFIX="$HOME/prefixes/rhel-headless"
export PATH="$PREFIX/bin:$PATH"

# Go nuts!
# export GOROOT="$PREFIX/go"
# export GOPATH="$PREFIX/gopath"
# export PATH="$GOROOT/bin:$GOPATH/bin:$PATH"

# Ruby - rbenv and rubygems
export RBENV_ROOT="$PREFIX/rbenv"
export PATH="$RBENV_ROOT/bin:$PATH"
eval "$(rbenv init -)"

# perl/cpan
# add-bundle-to-path "$PREFIX/perl5"
# source ~/prefixes/rhel-headless/perl5/etc/bashrc
