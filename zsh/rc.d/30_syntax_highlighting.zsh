# if syntax highlighting is installed, use it

local plugin="$ZSH_FILES/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh"
if [[ -f "$plugin" ]] ; then
    ZSH_HIGHLIGHT_HIGHLIGHTERS=(main brackets pattern)

    source "$plugin"

    ZSH_HIGHLIGHT_STYLES[root]='bg=red'
    ZSH_HIGHLIGHT_PATTERNS+=('rm -rf *' 'fg=white,bold,bg=red')
fi

