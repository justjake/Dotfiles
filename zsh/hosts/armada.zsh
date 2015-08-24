export GOPATH="$HOME/go"
export PATH="$GOPATH/bin:$PATH"
eval $(go env)

# src log
export gosrc="$GOPATH/src/github.com/justjake"

# virtualenv
export WORKON_HOME="/opt/virtualenvs"
source /etc/bash_completion.d/virtualenvwrapper

# N, the node version manager
export N_PREFIX="$HOME/bundles/n-prefix"

# geeeeeeeeeeeeeemas
# ruby ._.
export GEM_HOME=~/.gemhome
add_bundle_to_path $GEM_HOME
