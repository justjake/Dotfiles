JAVA_HOME="$HOME/bundles/java-latest"

# system virtualenv package
WORKON_HOME=~/virtualenv
source "/etc/bash_completion.d/virtualenvwrapper"

NPM_PACKAGES=~/bundles/npm-packages
conf='-c https://internal/conf2.yml'

if [[ $TERM = "screen-256color" ]]; then
    cd ~/src/squidwork
    workon zeromq
fi

# OPAM configuration
. /home/jitl/.opam/opam-init/init.zsh > /dev/null 2> /dev/null || true
