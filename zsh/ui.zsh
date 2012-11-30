#!/usr/bin/env zsh


#### Options
setopt NO_beep
setopt    auto_pushd
setopt    auto_cd
setopt    pushd_ignore_dups


#### Keybinds
# bindkey -v # VI keybinds # are rather odd on the CLI
bindkey ' ' magic-space    # also do history expansion on space
bindkey "^I" expand-or-complete-with-dots
bindkey '^[[A' up-line-or-search   # does search if you've entered text
bindkey '^[[B' down-line-or-search


##### load and style support for version control systems
autoload -Uz vcs_info
zstyle ':vcs_info:*' enable git hg
zstyle ':vcs_info:*' actionformats '%F{5}(%f%s%F{5})%F{3}-%F{5}[%F{2}%b%F{3}|%F{1}%a%F{5}]%f '
zstyle ':vcs_info:*' formats       '%F{5}(%f%s%F{5})%F{3}-%F{5}[%F{2}%b%F{5}]%f '
zstyle ':vcs_info:(sv[nk]|bzr):*' branchformat '%b%F{1}:%F{3}%r'


###### Colors and Prompt
autoload colors zsh/terminfo && colors
for color in BLACK RED GREEN YELLOW BLUE MAGENTA CYAN WHITE; do
	eval PR_LIGHT_$color='%{$terminfo[bold]$fg[${(L)color}]%}'
	eval PR_$color='%{$fg[${(L)color}]%}'
	(( count = $count + 1 ))
done
PR_RESET_COLOR="%{$reset_color%}"

export PS1="${PR_LIGHT_BLACK}[${PR_LIGHT_BLUE}%n${PR_LIGHT_BLACK}@${PR_RESET_COLOR}${PR_GREEN}%m${PR_LIGHT_BLACK}:${PR_LIGHT_GREEN}%2c${PR_LIGHT_BLACK}]${PR_RESET_COLOR}${PR_RED} %1v %(!.#.$)${PR_RESET_COLOR} "
export RPS1="${PR_LIGHT_BLACK}(%D{%m-%d %H:%M}) [%?]${PR_RESET_COLOR}" # shows exit status of previous command


#### Window Title
title () {
  # escape '%' chars in $1, make nonprintables visible
  a=${(V)1//\%/\%\%}

  # Strip newlines from command
  a=$(print -Pn "%70>...>$a" | tr -d "\n")
  local xtermtitle="\e]2;$2 $a\a"

  case $TERM in
  screen)
    print -Pn "$xtermtitle" # plain xterm title
    print -Pn "\ek$a\e\\"      # screen title (in ^A")
    print -Pn "\e_$2   \e\\"   # screen location
    ;;
  xterm*|rxvt)
    print -Pn "$xtermtitle" # plain xterm title
    ;;
  esac
}

TITLE_LOCATION="[%m:%~]"

# precmd is called just before the prompt is printed
function precmd() {
    title "zsh" "$TITLE_LOCATION"
    vcs_info
    psvar=()
    psvar[1]="$vcs_info_mgs_0_"
}

# preexec is called just before any command line is executed
function preexec() {
  title "$1" "$TITLE_LOCATION"
}
