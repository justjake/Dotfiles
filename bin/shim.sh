#!/bin/bash

# Transparent proxy script that logs arguments

SCRIPT="$0"
ARGS="$@"

# first log
echo "$(hostname) ran $0 $@" >> /tmp/shim.log &

# get the true name of the thing
NAME="$(basename "$0")"

PATH="$HOME/bin/true:$PATH" exec $NAME "$@"
