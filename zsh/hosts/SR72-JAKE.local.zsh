export HOMEBREW_CASK_OPTS="--appdir=$HOME/Applications"
export PATH="$PATH:$HOME/.claude/local"

# Notion
# eval "$(pyenv init -)"
# eval "$(rbenv init -)"
eval "$(notion completion --install)"

# 2*30s, the default, for airplane high latency env
export NOTION_AWS_SSO_LOGIN_TIMEOUT=60000
export NOTION_AWS_SSO_USE_DEVICE_AUTHORIZATION_API=true
export NOTION_NO_PREPUSH=1

perms-fn() {
  notion jit create-request --appName "AWS" --resourceName "AWS - notion-labs - postgres-secrets-admin" --duration "12 hours" --justification "ivm" --notifyMe=false
  notion jit create-request --appName "AWS" --resourceName "(AWS SSO PROD) Infrastructure" --duration "12 hours" --justification "ivm" --notifyMe=false
}
alias perms=perms-fn

add_bundle_to_path /opt/homebrew/opt/postgresql@15
add_bundle_to_path "$HOME/bundles/mz"
export NOTION_IVM=1

alias gn="goto notion-next"
eval "$(kubectl completion zsh)"
eval "$(notion shellenv)"
source "$NOTION_SHELL/cell.sh"

prompt_info_section_functions+=(prompt_info_k8s_context)
prompt_info_k8s_context() {
  format_prompt_info_section "k8s" "$(yq '.current-context' ~/.kube/config)"
}

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

alias dbbench=/Users/jitl/src/dbbench/dbbench

export NOTION_NODE_OPTIONS=--heapsnapshot-near-heap-limit=4
export K9S_CONFIG_DIR="$HOME/.config/k9s"
export K9S_FEATURE_GATE_NODE_SHELL=true

declare -g -A ENVIRONMENTS_TINY=(
	[local]="l"
	[development]="d"
	[staging]="s"
	[production]="p"
)

declare -g -A REGIONS_TINY=(
  ["us-west-2"]=""
	["eu-central-1"]="e"
)

cell-type-tiny() {
  local cell_id="$1"
  eval declare -A cell="$(cell_info_from_cell_id "$cell_id")"
  case "${cell[type]}" in
    main)
      echo m
      ;;
    xcell)
      echo x
      ;;
    space)
      echo "${cell[number]}"
      ;;
    *)
      echo "error: unknown cell type '${cell[type]}'" >&2
      return 1
      ;;
  esac
}

cell-id-tiny() {
  local cell_id="$1"
  eval declare -A cell="$(cell_info_from_cell_id "$cell_id")"

  local env_tiny="${ENVIRONMENTS_TINY[${cell[env]}]}"
  local region_tiny="${REGIONS_TINY[${cell[region]}]}"
  local type_tiny
  type_tiny="$(cell-type-tiny "$cell_id")"

  # space cell 1 in eu is referred to just by the region 'e'
  if [[ "$region_tiny" == "e" && "$type_tiny" == 1 ]] ; then
    echo "${env_tiny}${region_tiny}"
    return 0
  fi

  echo "${env_tiny}${region_tiny}${type_tiny}"
}

def-cell-alias() {
  local prefix="$1"
  local template="$2"
  local cell_id="$3"

  local alias_name="${prefix}$(cell-id-tiny "$cell_id")"
  local expanded
  expanded="$(eval echo "$template")"
  alias "$alias_name"="$expanded"
}

def-space-cell-alias() {
  if [[ "${cell[type]}" != space || "${cell[env]}" == local ]] ; then
    return 0
  fi
  def-cell-alias "$@"
}

for-each-cell() {
	for cell_id in "${CELL_IDS[@]}"; do
		eval declare -g -A cell="$(cell_info_from_cell_id "$cell_id")"
	  "$@" "$cell_id"
	done
}

for-each-cell def-space-cell-alias k 'kubectl --context mz-$cell_id'
for-each-cell def-space-cell-alias k9 'k9s --context mz-$cell_id'
for-each-cell def-space-cell-alias h 'helm --kube-context=mz-$cell_id'
for-each-cell def-space-cell-alias mzui 'notion ivm go --cellId=$cell_id --instance'
alias mzuip1.1='mzuip1 1'
alias mzuip1.2='mzuip1 2'
alias mzuip2.1='mzuip2 1'
alias mzuip2.2='mzuip2 2'

# alias kp1='kubectl --context mz-prod-space-usw2-0001'
# alias kp2='kubectl --context mz-prod-space-usw2-0002'
# alias kp3='kubectl --context mz-prod-space-usw2-0003'
# alias kp4='kubectl --context mz-prod-space-usw2-0004'
# alias kpe='kubectl --context mz-prod-space-euc1-0001'
# 
# alias ks1='kubectl --context mz-stg-space-usw2-0001'
# 
# alias kd1='kubectl --context mz-dev-space-usw2-0001'
# alias kd2='kubectl --context mz-dev-space-usw2-0002'
# alias kde='kubectl --context mz-dev-space-euc1-0001'
# 
# alias k9p1="k9s --context mz-prod-space-usw2-0001"
# alias k9p2="k9s --context mz-prod-space-usw2-0002"
# alias k9p3="k9s --context mz-prod-space-usw2-0003"
# alias k9p4="k9s --context mz-prod-space-usw2-0004"
# alias k9pe="k9s --context mz-prod-space-euc1-0001"
# 
# alias k9s1="k9s --context mz-stg-space-usw2-0001"
# 
# alias k9d1="k9s --context mz-dev-space-usw2-0001"
# alias k9d2="k9s --context mz-dev-space-usw2-0002"
# alias k9de="k9s --context mz-dev-space-euc1-0001"

notionadmin-password () {
  local env
  env="${1:-prod}"
  notion secrets get --name -postgres-admin --env "$env" | jq .data.password -r | pbcopy
}

mzsystem-password () {
  local env
  env="${1:-prod}"
  notion secrets get --name materialize-mz_system-user --env "$env" | jq .password -r | pbcopy
}

alias adminp='notionadmin-password prod'
alias admind='notionadmin-password dev'
alias admins='notionadmin-password stg'

alias mzp="mzsystem-password prod"
alias mzs="mzsystem-password stg"
alias mzd="mzsystem-password dev"


export PATH="${KREW_ROOT:-$HOME/.krew}/bin:$PATH"
eval "$(~/.local/bin/mise activate zsh)"

export NOTION_I_AM_A_DATABASE_EXPERT_AND_WILL_BE_FIRED_IF_I_CAUSE_AN_INCIDENT=1
export NOTION_BYPASS_POSTGRES_PROXY=1

claude-key() {
  export ANTHROPIC_API_KEY="$(op item get 'Notion Anthropic API Token' --reveal --field password)"
}


mztf () {
  mise deactivate
  cd "$(goto-which notion-next)/terraform/aws/next/cell/services/materialize_dot_com"
}

# STATSIG_DISABLED=true
STATSIG_INIT_FROM_MS=1
