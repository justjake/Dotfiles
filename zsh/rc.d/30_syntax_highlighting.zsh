# if syntax highlighting is installed, use it
ZSH_HIGHLIGHT_HIGHLIGHTERS=(main brackets pattern cursor)

jitl-highlight-if-availible () {
    local plugin="$ZSH_FILES/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh"
    if [[ -f "$plugin" ]] ; then
        source "$plugin"
    fi
}

jitl-highlight-if-availible
