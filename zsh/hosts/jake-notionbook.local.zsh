add-bundle-to-path /usr/local/opt/node@10
add-bundle-to-path "$HOME/bundles/npm-hack"

# Also use node_modules
export PATH="$PATH:./node_modules/.bin"

if which nvim > /dev/null 2>&1; then
  alias vi=vim
  alias vim=nvim
fi

alias google-chrome="'/Applications/Google Chrome.app/Contents/MacOS/Google Chrome'"
