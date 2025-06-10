### VCS module required
autoload -Uz vcs_info
zstyle ':vcs_info:*' enable git hg
zstyle ':vcs_info:*' actionformats '%F{0}[%f%s%F{5}:%F{3}%F{5}%F{2}%b%F{3}|%F{1}%a%F{0}]%f'
zstyle ':vcs_info:*' formats       '%F{0}[%f%s%F{5}:%F{3}%F{5}%F{2}%b%F{0}]%f'
zstyle ':vcs_info:(sv[nk]|bzr):*' branchformat '%b%F{1}:%F{3}%r'

### Colors and Prompt
prompt_opts=(cr percent subst)
setopt prompt_subst
autoload colors zsh/terminfo && colors
for color in BLACK RED GREEN YELLOW BLUE MAGENTA CYAN WHITE; do
	eval export PR_LIGHT_$color='%{$terminfo[bold]$fg[${(L)color}]%}'
	eval export PR_$color='%{$fg[${(L)color}]%}'
	(( count = $count + 1 ))
done
PR_RESET_COLOR="%{$reset_color%}"
PR_BOLD="%{$terminfo[bold]%}"

typeset -a precmd_functions
typeset -a prompt_info_section_functions
prompt_info_secton_data=""

precmd_functions+=(render_prompt_info_section)
render_prompt_info_section() { 
  prompt_info_section_data=""
  for fn_name in "${prompt_info_section_functions[@]}" ; do
    prompt_info_section_data+="$($fn_name)"
  done
}

format_prompt_info_section() {
  local key=""
  local value="$1"
  if [[ $# -gt 1 ]]; then
    key="$1"
    value="$2"
  fi

  local section_open="${PR_LIGHT_BLACK}[${PR_RESET_COLOR}"
  local section_close="${PR_LIGHT_BLACK}]${PR_RESET_COLOR}"
  local key_open="${PR_BOLD}"
  local key_close="${PR_LIGHT_MAGENTA}:${PR_LIGHT_GREEN}"

  local result="${section_open}"
  if [[ -n "$key" ]] ; then
    result+="${key_open}${key}${key_close}"
  fi
  result+="${value}${section_close}"

  echo -n "${result}"
}

export PROMPT='${PR_LIGHT_BLACK}[${PR_LIGHT_BLUE}%n${PR_LIGHT_BLACK}@${PR_RESET_COLOR}${PR_GREEN}%m${PR_LIGHT_BLACK}:${PR_LIGHT_GREEN}%2c${PR_LIGHT_BLACK}]${PR_RESET_COLOR}${PR_LIGHT_BLACK}${vcs_info_msg_0_}${PR_RESET_COLOR}${prompt_info_section_data} ${PR_LIGHT_BLACK}%D{%m-%d %H:%M} [%?]
${PR_RESET_COLOR}${PR_RED}%(!.#.$)${PR_RESET_COLOR} '
