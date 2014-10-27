export GOPATH="$HOME/go"
export PATH="$GOPATH/bin:$PATH"
eval $(go env)

# src log
export gosrc="$GOPATH/src/github.com/justjake"

# virtualenv
export WORKON_HOME="/opt/virtualenvs"
source /etc/bash_completion.d/virtualenvwrapper