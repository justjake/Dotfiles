export HOMEBREW_CASK_OPTS="--appdir=$HOME/Applications"

# Notion
eval "$(pyenv init -)"
eval "$(rbenv init -)"
eval "$(direnv hook zsh)"
eval "$(notion completion --install)"
