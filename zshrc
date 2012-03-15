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
source "$HOME/.zsh/completion.zsh"

####
# Misc Options
####
setopt    extended_glob
setopt    long_list_jobs

####
# User Interface
####
source "$HOME/.zsh/ui.zsh" # prompt and title
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
