# paths in which to find projects or directories
# top path wins
goto_search_paths=(
  $GOPATH/*/*
  ~/airlab-stable/repos
  ~/src
)

goto () {
  for p in $goto_search_paths; do
    local it="$p/$1"
    if [ -e "$it" ] ; then
      echo "cd $it"
      cd "$it"
      return 0
    fi
  done

  # fallback: try to resolve via role name`
  lab cd "$@"
}

_goto () {
  # TODO
}
