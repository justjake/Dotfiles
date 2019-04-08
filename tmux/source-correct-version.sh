#!/bin/sh

verify_tmux_verision () {
  tmux_home=~/.dotfiles/tmux
  tmux_version="`tmux -V | cut -c 6-`"

  if [ `echo "$tmux_version >= 2.8" | bc` -eq 1 ]; then
    tmux source-file "$tmux_home/tmux_ge_28.conf"
    exit 0
  elif [ `echo "$tmux_version >= 2.1" | bc` -eq 1 ]; then
    tmux source-file "$tmux_home/tmux_21_28.conf"
    exit 0
  else
    tmux source-file "$tmux_home/tmux_lt_21.conf"
    exit 0
  fi
}

verify_tmux_verision
