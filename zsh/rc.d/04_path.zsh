# Make path elements unique
typeset -U path PATH

_path_append() {
  if [[ -d "$1" ]]; then
    path+=("$1")
  fi
}

_path_prepend() {
  if [[ -d "$1" ]]; then
    path[1,0]="$1"
  fi
}

# TODO: make bundles zsh-only, integrate with this
_path_prepend /opt/homebrew/bin
_path_prepend /usr/local/bin
_path_prepend "$HOME/bin"
