# Aliases for directories outside of search paths
typeset -A goto_names
goto_names=(
  dotfiles ~/.dotfiles
  zsh      ~/.dotfiles/zsh
)

# paths in which to find projects or directories
# top path wins
goto-refresh-search-paths () {
  setopt nullglob
  goto_search_paths=(
    $GOPATH/src/*/*
    ~/airlab/repos
    ~/src
    ~/src/disabled-repos
  )
  unsetopt nullglob
}


goto-which () {
  local quiet=false
  if [[ "$1" == "--quiet" ]]; then
    quiet=true
    shift
  fi

  local lookup="${goto_names[$1]}"
  if [[ -n "$lookup" ]] ; then
    echo "$lookup"
    return 0
  fi

  goto-refresh-search-paths
  for p in $goto_search_paths; do
    local it="$p/$1"
    if [ -e "$it" ] ; then
      echo "$it"
      return 0
    fi
  done

  if [[ quiet != true ]] ; then
    echo "goto-which: not found: $1" > /dev/stderr
  fi
  return 1
}

goto () {
  local dir="$(goto-which --quiet "$1")"
  if [ -n "$dir" ]; then
    echo "cd $dir"
    cd "$dir"
  else
    echo "goto: not found: $1" > /dev/stderr
    return 1
  fi
}

_goto () {
  goto-refresh-search-paths
  COMPREPLY=()

  # Only complete one word
  if [[ $COMP_CWORD -gt 1 ]]; then
    return 0
  fi

  # Complete with matching paths inside our search paths
  local cur
  cur="${COMP_WORDS[COMP_CWORD]}"

  local path_glob
  local candidates
  for p in "${goto_search_paths[@]}"; do
    # Loop through all the search paths and see if we can glob anything
    # beginning with the user's typing.
    path_glob="$p/$cur*"
    candidates=($(compgen -G "$path_glob" | xargs basename))
    # Add any matches to the completion result
    COMPREPLY+=( "${candidates[@]}" )
  done

  return 0
}

if [[ "$SHELL" == *"zsh" ]]; then
  autoload bashcompinit
  bashcompinit
fi

complete -F _goto goto
complete -F _goto goto-which
