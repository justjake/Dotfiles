#### Options
setopt NO_beep
setopt    auto_pushd
setopt    auto_cd
setopt    pushd_ignore_dups

#### Keybinds
# bindkey -v # VI keybinds # are rather odd on the CLI
bindkey -e  # I couldn't adapt to VI vs VIM things in bindkey -v
bindkey ' ' magic-space    # also do history expansion on space
bindkey "^I" expand-or-complete-with-dots
bindkey '^[[A' up-line-or-search   # does search if you've entered text
bindkey '^[[B' down-line-or-search

##### load and style support for version control systems
autoload -Uz add-zsh-hook

#### LS Colors
command-exists dircolors &&  eval $(dircolors  -b "$DOTFILES/lscolors/dircolors.zenburn.older")
command-exists gdircolors && eval $(gdircolors -b "$DOTFILES/lscolors/dircolors.zenburn.older")
