# if syntax highlighting is installed, use it
ZSH_HIGHLIGHT_HIGHLIGHTERS=(main brackets pattern)

local plugin="$ZSH_FILES/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh"
if [[ -f "$plugin" ]] ; then
    source "$plugin"
fi

ZSH_HIGHLIGHT_STYLES[root]='bg=red'
ZSH_HIGHLIGHT_PATTERNS+=('rm -rf *' 'fg=white,bold,bg=red')
