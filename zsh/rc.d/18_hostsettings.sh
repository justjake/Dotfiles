# hostsettings            - Edit the current host's settings
# hostsettings <hostname> - Edit the given host's settings
# host-use <hostname>     - Use the given host's settings for this host

hostsettings () {
  local target_host="${1:-$HOSTNAME}"
  "$EDITOR" "$ZSH_FILES/hosts/$target_host.zsh"
}

host-use () {
  local other_host="$1"

	(
		pushd "$ZSH_FILES/hosts/" no-output
		if [[ -e "$other_host".zsh ]] ; then
			ln -sv "$other_host".zsh `hostname`.zsh
		elif [[ -e "$other_host" ]] ; then
			ln -sv "$other_host" `hostname`.zsh
		else
			echo "Host not found: $other_host" > /dev/stderr
			return 1
		fi
	)
}

alias use-host=host-use

_hostsettings_complete () {
  goto-refresh-search-paths
  COMPREPLY=()

  # Only complete one word
  if [[ $COMP_CWORD -gt 1 ]]; then
    return 0
  fi

  # Complete with matching paths inside our search paths
  local cur
  cur="${COMP_WORDS[COMP_CWORD]}"
  local path_glob="$ZSH_FILES/hosts/$cur*"
  local candidates=($(compgen -G "$path_glob" | xargs basename -s .zsh))
  # Add all candidates to the reply
  COMPREPLY+=( "${candidates[@]}" )

  return 0
}

if [[ "$SHELL" == *"zsh" ]]; then
  autoload bashcompinit
  bashcompinit
fi

complete -F _hostsettings_complete hostsettings
complete -F _hostsettings_complete host-use
complete -F _hostsettings_complete use-host
