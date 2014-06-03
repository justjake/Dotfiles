source "$ZSH_FILES/hosts/rhel-headless.zsh"

export CODE="/usr/code/jitl"
# Python devbox
export WORKON_HOME="$CODE/virtualenvs"
source $(which virtualenvwrapper.sh)

if [[ $TERM == 'screen-256color' ]]; then
    workon scunc
fi
