#!/usr/bin/env zsh
####
#   Jake's .zshrc
#   <just.1.jake@gmail.com>
####
# export all of these settings
setopt ALL_EXPORT

MANSECT=1:1p:8:2:3:3p:4:5:6:7:9:0p:n:l:o
TZ="America/Los_Angeles"
HOSTNAME="`hostname`"
PAGER='less'
EDITOR='vim'
SVN_EDITOR="$EDITOR"
VISUAL="$EDITOR"
#LANGUAGE=
LANG='en_US.UTF-8'
LC_ALL='en_US.UTF-8'
LC_CTYPE=C

####
# Colors and Prompt
####
# map colorterms to xterm-256color support
if [[ $COLORTERM == "roxterm" || $COLORTERM == "gnome-terminal" ]]; then
    TERM=xterm-256color
fi

autoload -U colors zsh/terminfo && colors

for color in BLACK RED GREEN YELLOW BLUE MAGENTA CYAN WHITE; do
	eval PR_LIGHT_$color='%{$terminfo[bold]$fg[${(L)color}]%}'
	eval PR_$color='%{$fg[${(L)color}]%}'
	(( count = $count + 1 ))
done
PR_NO_COLOR="%{$terminfo[sgr0]%}"

# prompt
PS1="${PR_LIGHT_BLACK}[$PR_LIGHT_BLUE%n${PR_LIGHT_BLACK}@$PR_NO_COLOR$PR_GREEN%m${PR_LIGHT_BLACK}:$PR_LIGHT_GREEN%2c${PR_LIGHT_BLACK}]$PR_NO_COLOR$PR_RED %(!.#.$)$PR_NO_COLOR "
RPS1="$PR_LIGHT_BLACK(%D{%m-%d %H:%M})$PR_NO_COLOR"

####
# History
####
HISTFILE="$HOME/.zsh/cache/`hostname`.zhistory"
HISTSIZE=100000
SAVEHIST=100000
setopt hist_ignore_dups
setopt hist_verify
setopt inc_append_history
setopt extended_history
setopt hist_expire_dups_first
setopt hist_ignore_space
setopt share_history

unsetopt ALL_EXPORT

####
# Other ZSH Settings
####
setopt no_beep
setopt auto_cd
setopt auto_pushd
setopt pushd_ignore_dups
setopt extended_glob
setopt long_list_jobs


####
# Completion
####
source .zsh/completion.zsh


####
# Keybinds
####
bindkey ' ' magic-space    # also do history expansion on space
bindkey "^I" expand-or-complete-with-dots


####
# Source external files
####
source "$HOME/.zsh/aliases.zsh"
[[ -f "$HOME/.zsh/hosts/`hostname`" ]] && source "$HOME/.zsh/hosts/`hostname`"
