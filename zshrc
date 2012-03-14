#!/usr/bin/env zsh
####################################################
#  Jake Teton-Landis's                       ZSHRC #
# <just.1.jake@gmail.com>              Winter 2012 #
####################################################
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

autoload colors zsh/terminfo && colors

for color in BLACK RED GREEN YELLOW BLUE MAGENTA CYAN WHITE; do
	eval PR_LIGHT_$color='%{$terminfo[bold]$fg[${(L)color}]%}'
	eval PR_$color='%{$fg[${(L)color}]%}'
	(( count = $count + 1 ))
done
PR_RESET_COLOR="%{$reset_color%}"

# prompt
PS1="${PR_LIGHT_BLACK}[${PR_LIGHT_BLUE}%n${PR_LIGHT_BLACK}@${PR_RESET_COLOR}${PR_GREEN}%m${PR_LIGHT_BLACK}:${PR_LIGHT_GREEN}%2c${PR_LIGHT_BLACK}]${PR_RESET_COLOR}${PR_RED} %(!.#.$)${PR_RESET_COLOR} "
RPS1="${PR_LIGHT_BLACK}(%D{%m-%d %H:%M}) [%?]${PR_RESET_COLOR}" # shows exit status of previous command

####
# History
####
HISTFILE="$HOME/.zsh/cache/`hostname`.zhistory"
HISTSIZE=130000
SAVEHIST=100000
setopt NO_ALL_EXPORT
setopt    hist_ignore_dups
setopt NO_hist_verify # enable to review `sudo !!` before executing
setopt    inc_append_history
setopt    extended_history
setopt    hist_expire_dups_first
setopt    hist_ignore_space
# annoying when different terminals do different tasks
setopt NO_share_history


####
# Completion
####
source .zsh/completion.zsh

####
# Misc Options
####
setopt    extended_glob
setopt    long_list_jobs

####
# User Interface
#### Options
setopt NO_beep
setopt    auto_pushd
setopt    auto_cd
setopt    pushd_ignore_dups
#### Keybinds
bindkey -v # VI keybinds
bindkey ' ' magic-space    # also do history expansion on space
bindkey "^I" expand-or-complete-with-dots

####
# Host-specific Settings
####
[[ -f "$HOME/.zsh/hosts/`hostname`" ]] && source "$HOME/.zsh/hosts/`hostname`"

####
# Aliases
####
source "$HOME/.zsh/aliases.zsh"
