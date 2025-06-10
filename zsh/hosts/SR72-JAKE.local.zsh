export HOMEBREW_CASK_OPTS="--appdir=$HOME/Applications"

# Notion
eval "$(pyenv init -)"
eval "$(rbenv init -)"
eval "$(direnv hook zsh)"
eval "$(notion completion --install)"

# 2*30s, the default, for airplane high latency env
export NOTION_AWS_SSO_LOGIN_TIMEOUT=60000
export NOTION_NO_PREPUSH=1

alias perms='notion jit create-request --appName "AWS" --resourceName "(AWS SSO PROD) Infrastructure" --duration "12 hours" --justification "ivm" --notifyMe=false'

add_bundle_to_path /opt/homebrew/opt/postgresql@15
add_bundle_to_path "$HOME/bundles/mz"
export NOTION_IVM=1

alias gn="goto notion-next"
eval "$(kubectl completion zsh)"
eval "$(notion shellenv)"
source "$NOTION_SHELL/cell.sh"

prompt_info_section_functions+=(prompt_info_tf_cell)
prompt_info_tf_cell() {
  if [[ -n "$TF_CELL_ID" ]]; then
    format_prompt_info_section "cell" "$TF_CELL_ID"
  fi
}

prompt_info_section_functions+=(prompt_info_aws_profile)
prompt_info_aws_profile() {
  if [[ -n "$AWS_PROFILE" ]]; then
    format_prompt_info_section "aws" "$AWS_PROFILE"
  fi
  if [[ -n "$AWS_DEFAULT_REGION" ]]; then
    format_prompt_info_section "region" "$AWS_DEFAULT_REGION"
  fi
}
