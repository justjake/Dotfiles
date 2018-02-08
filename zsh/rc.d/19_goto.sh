# paths in which to find projects or directories
# top path wins
goto-refresh-search-paths () {
  goto_search_paths=(
    $GOPATH/src/*/*
    ~/airlab-stable/repos
    ~/src
    ~/src/disabled-repos
  )
}

goto-which () {
  goto-refresh-search-paths
  for p in $goto_search_paths; do
    local it="$p/$1"
    if [ -e "$it" ] ; then
      echo "$it"
      return 0
    fi
  done

  echo "goto-which: not found: $1" > /dev/stderr
  return 1
}

goto () {
  goto-refresh-search-paths
  local dir=$(goto-which "$1")
  if [ -n "$dir" ]; then
    echo "cd $dir"
    cd "$dir"
  else
    # fallback: try to resolve via role name
    lab cd "$@"
  fi
}

_goto () {
  goto-refresh-search-paths
  echo "_goto: $COMP_CWORD" >&2
  COMPREPLY=()

  # Only complete one word
  if [[ $COMP_CWORD -gt 1 ]]; then
    return 0
  fi

  # Complete with matching paths inside our search paths
  local cur
  cur="${COMP_WORDS[COMP_CWORD]}"
  echo "_goto: cur = ${cur}" >&2

  for p in $goto_search_paths; do
    COMPREPLY+=("$p/$cur"*)
  done
}

if [[ "$SHELL" == *"zsh" ]]; then
  autoload bashcompinit
  bashcompinit
fi

complete -F _goto goto
complete -F _goto goto-which
