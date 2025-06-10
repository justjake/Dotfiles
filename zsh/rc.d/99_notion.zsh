
	if [[ -n "$ZSH_VERSION" ]]; then
		if ! type bashcompinit &>/dev/null; then
			autoload bashcompinit
			bashcompinit
		fi
	fi

	if type complete &>/dev/null; then
  _notion_completion () {
    local words cword
    if type _get_comp_words_by_ref &>/dev/null; then
      _get_comp_words_by_ref -n = -n @ -n : -w words -i cword
    else
      cword="$COMP_CWORD"
      words=("${COMP_WORDS[@]}")
    fi

    local si="$IFS"
	# TODO: put back /dev/null
    IFS=$'\n' COMPREPLY=($(COMP_CWORD="$cword" \
                           COMP_LINE="$COMP_LINE" \
                           COMP_POINT="$COMP_POINT" \
                           /usr/local/bin/node --max-old-space-size=8192 --trace-warnings --trace-deprecation --stack-trace-limit=100 -r /Users/jitl/src/notion-next/esbuild-runner.js /Users/jitl/src/notion-next/src/cli/main/notion.ts completion -- "$1" "$2" "$3" "${words[@]}" \
                           2>/dev/null)) || return $?
    IFS="$si"
    if type __ltrim_colon_completions &>/dev/null; then
      __ltrim_colon_completions "${words[cword]}"
    fi
  };
  complete -o default -o nospace -F _notion_completion notion;
fi

# Always run this to avoid installing this command repeatedly.
export NOTION_INSTALL_NO_COMPLETION=1;

