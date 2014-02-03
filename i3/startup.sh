#!/usr/bin/env zsh

# VMware User for clipboard
vmware-user &

# start a terminal
i3-sensible-terminal &

# and a browser, too, cause those are the two things we do
$BROWSER &
