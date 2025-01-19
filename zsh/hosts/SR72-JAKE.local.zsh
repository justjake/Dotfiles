export HOMEBREW_CASK_OPTS="--appdir=$HOME/Applications"

# Notion
eval "$(pyenv init -)"
eval "$(rbenv init -)"
eval "$(direnv hook zsh)"
eval "$(notion completion --install)"

# 2*30s, the default, for airplane high latency env
export NOTION_AWS_SSO_LOGIN_TIMEOUT=60000
export NOTION_NO_PREPUSH=1

alias perms='notion jit create-request --appName "AWS" --resourceName "(AWS SSO PROD) Infrastructure" --duration "12 hours" --justification "debezium"'

add_bundle_to_path /opt/homebrew/opt/postgresql@15
export NOTION_IVM=1
