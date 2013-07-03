#!/usr/bin/env zsh


#### Options
setopt NO_beep
setopt    auto_pushd
setopt    auto_cd
setopt    pushd_ignore_dups


#### Keybinds
# bindkey -v # VI keybinds # are rather odd on the CLI
bindkey -e   # all hail our new emacs overlords
bindkey ' ' magic-space    # also do history expansion on space
bindkey "^I" expand-or-complete-with-dots
bindkey '^[[A' up-line-or-search   # does search if you've entered text
bindkey '^[[B' down-line-or-search


##### load and style support for version control systems
autoload -Uz add-zsh-hook
autoload -Uz vcs_info
zstyle ':vcs_info:*' enable git hg
zstyle ':vcs_info:*' actionformats '%F{5}(%f%s%F{5})%F{3}-%F{5}[%F{2}%b%F{3}|%F{1}%a%F{5}]%f '
zstyle ':vcs_info:*' formats       '%F{5}(%f%s%F{5})%F{3}-%F{5}[%F{2}%b%F{5}]%f '
zstyle ':vcs_info:(sv[nk]|bzr):*' branchformat '%b%F{1}:%F{3}%r'


##### Colors and Prompt

analog-clock-time() {
    local time=$(date +%I%M);
    if [ "$time" -lt 115 ]
    then
        echo -n '🕐'
    elif [ "$time" -lt 145 ]
    then
        echo -n '🕜'
    elif [ "$time" -lt 215 ]
    then
        echo -n '🕑'
    elif [ "$time" -lt 245 ]
    then
        echo -n '🕝'
    elif [ "$time" -lt 315 ]
    then
        echo -n '🕒'
    elif [ "$time" -lt 345 ]
    then
        echo -n '🕞'
    elif [ "$time" -lt 415 ]
    then
        echo -n '🕓'
    elif [ "$time" -lt 445 ]
    then
        echo -n '🕟'
    elif [ "$time" -lt 515 ]
    then
        echo -n '🕔'
    elif [ "$time" -lt 545 ]
    then
        echo -n '🕠'
    elif [ "$time" -lt 615 ]
    then
        echo -n '🕕'
    elif [ "$time" -lt 645 ]
    then
        echo -n '🕡'
    elif [ "$time" -lt 715 ]
    then
        echo -n '🕖'
    elif [ "$time" -lt 745 ]
    then
        echo -n '🕢'
    elif [ "$time" -lt 815 ]
    then
        echo -n '🕗'
    elif [ "$time" -lt 845 ]
    then
        echo -n '🕣'
    elif [ "$time" -lt 915 ]
    then
        echo -n '🕘'
    elif [ "$time" -lt 945 ]
    then
        echo -n '🕤'
    elif [ "$time" -lt 1015 ]
    then
        echo -n '🕙'
    elif [ "$time" -lt 1045 ]
    then
        echo -n '🕥'
    elif [ "$time" -lt 1115 ]
    then
        echo -n '🕚'
    elif [ "$time" -lt 1145 ]
    then
        echo -n '🕦'
    elif [ "$time" -lt 1215 ]
    then
        echo -n '🕛'
    elif [ "$time" -lt 1300 ]
    then
        echo -n '🕛'
    else
        echo -n '⭕'
    fi
}

prompt_opts=(cr percent subst)

autoload colors zsh/terminfo && colors
for color in BLACK RED GREEN YELLOW BLUE MAGENTA CYAN WHITE; do
	eval PR_LIGHT_$color='%{$terminfo[bold]$fg[${(L)color}]%}'
	eval PR_$color='%{$fg[${(L)color}]%}'
	(( count = $count + 1 ))
done
PR_RESET_COLOR="%{$reset_color%}"

export PROMPT='${PR_LIGHT_BLACK}[${PR_LIGHT_BLUE}%n${PR_LIGHT_BLACK}@${PR_RESET_COLOR}${PR_GREEN}%m${PR_LIGHT_BLACK}:${PR_LIGHT_GREEN}%2c${PR_LIGHT_BLACK}]${PR_RESET_COLOR}${PR_RED} %(!.#.$)${PR_RESET_COLOR} '
export RPROMPT='${PR_LIGHT_BLACK}(%D{%m-%d %H:%M}) [%?] ${vcs_info_msg_0_}${PR_RESET_COLOR}' # shows exit status of previous command

use-utf8-clock () {
    export RPROMPT='$(analog-clock-time)  ${PR_LIGHT_BLACK}(%D{%m-%d %H:%M}) [%?] ${vcs_info_msg_0_}${PR_RESET_COLOR}' # shows exit status of previous command
}

#### LS Colors
command-exists dircolors &&  eval $(dircolors  -b "$DOTFILES/lscolors/dircolors.zenburn.older")
command-exists gdircolors && eval $(gdircolors -b "$DOTFILES/lscolors/dircolors.zenburn.older")



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
  xterm*|rxvt*)
    print -Pn "$xtermtitle" # plain xterm title
    ;;
  esac
}

TITLE_LOCATION="[%m:%~]"

# precmd is called just before the prompt is printed
function jake-precmd {
    title "zsh" "$TITLE_LOCATION"
    vcs_info
}

# preexec is called just before any command line is executed
function jake-preexec() {
  title "$1" "$TITLE_LOCATION"
}

#### Add ZSH pre-command hook
add-zsh-hook precmd jake-precmd
add-zsh-hook preexec jake-preexec
