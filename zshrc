#!/usr/bin/env zsh
####################################################
#  Jake Teton-Landis's                       ZSHRC #
# <just.1.jake@gmail.com>              Winter 2012 #
####################################################
# export all of these settings
setopt ALL_EXPORT

MANSECT=1:1p:8:2:3:3p:4:5:6:7:9:0p:n:l:o
TZ="America/Los_Angeles"
HOSTNAME="$(hostname -f)"
PAGER='less'
if which nvim > /dev/null 2>&1 ; then
  EDITOR='nvim'
else
  EDITOR='vim'
fi
# set SVN_EDITOR only if unset
[ -z "$SVN_EDITOR" ] && SVN_EDITOR="$EDITOR"
VISUAL="$EDITOR"
#LANGUAGE=
LC_ALL='en_US.UTF-8'

DOTFILES="$HOME/.dotfiles"
ZSH_FILES="$DOTFILES/zsh"


####
# User Scripts Directory in Path
####
PATH="$HOME/bin:$PATH"

#### History Settings
HISTFILE="${ZSH_FILES}/history/global.zhistory"
HISTSIZE=1300000
SAVEHIST=1000000
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
# Misc Options
####
setopt    extended_glob
setopt    long_list_jobs

# deal with Gnome Terminal being silly
if [[ $COLORTERM == "gnome-terminal" ]] ; then
    export TERM="xterm-256color"
fi

####
# Zshrc.d - most other config
# 00 - 09: functions
# 10 - 19: UI. title, prompt, keybindings, etc
# 20 - 29: Aliases.
# 99     : jokes and deprecated
####
for config in "$ZSH_FILES/rc.d"/* ; do
    # echo "loading $config"
    source "$config"
done
# source "$ZSH_FILES"/zshrc.d/*

#### Host Settings
[[ -f "$ZSH_FILES/hosts/$HOSTNAME" ]] && source "$ZSH_FILES/hosts/$HOSTNAME"
[[ -f "$ZSH_FILES/hosts/$HOSTNAME.zsh" ]] && source "$ZSH_FILES/hosts/$HOSTNAME.zsh"
[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh
