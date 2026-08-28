#### Window Title
title () {
  # Make nonprintables visible.
  local running_cmd="${(V)1}"

  if (( ${#running_cmd} > 70 )); then
    running_cmd="${running_cmd[1,67]}..."
  fi

  local title="$2 $running_cmd"
  local xtermtitle=$'\e]2;'"$title"$'\a'

  case $TERM in
  screen*)
    print -rn -- "$xtermtitle" # plain xterm title
    print -rn -- $'\ek'"$title"$'\e\\' # screen title (in ^A")
    print -rn -- $'\e_'"$2"$'\e\\'   # screen location
    ;;
  xterm*|rxvt*)
    print -rn -- "$xtermtitle" # plain xterm title
    ;;
  esac
}

# precmd is called just before the prompt is printed
function jake-precmd {
    title "zsh" "${PWD/#$HOME/~}"
    vcs_info
}

# preexec is called just before any command line is executed
function jake-preexec() {
  title "$1" "${PWD/#$HOME/~}"
}

#### Add ZSH pre-command hook
add-zsh-hook precmd jake-precmd
add-zsh-hook preexec jake-preexec
