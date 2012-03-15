#!/usr/bin/env zsh
####
# Colors and Prompt
####
# map colorterms to xterm-256color support
if [[ $COLORTERM == "roxterm" || $COLORTERM == "gnome-terminal" ]]; then
    export TERM=xterm-256color
fi

autoload colors zsh/terminfo && colors
for color in BLACK RED GREEN YELLOW BLUE MAGENTA CYAN WHITE; do
	eval PR_LIGHT_$color='%{$terminfo[bold]$fg[${(L)color}]%}'
	eval PR_$color='%{$fg[${(L)color}]%}'
	(( count = $count + 1 ))
done
PR_RESET_COLOR="%{$reset_color%}"

# prompt
export PS1="${PR_LIGHT_BLACK}[${PR_LIGHT_BLUE}%n${PR_LIGHT_BLACK}@${PR_RESET_COLOR}${PR_GREEN}%m${PR_LIGHT_BLACK}:${PR_LIGHT_GREEN}%2c${PR_LIGHT_BLACK}]${PR_RESET_COLOR}${PR_RED} %(!.#.$)${PR_RESET_COLOR} "
export RPS1="${PR_LIGHT_BLACK}(%D{%m-%d %H:%M}) [%?]${PR_RESET_COLOR}" # shows exit status of previous command

####
# Title
####
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
}

# preexec is called just before any command line is executed
function preexec() {
  title "$1" "$TITLE_LOCATION"
}
