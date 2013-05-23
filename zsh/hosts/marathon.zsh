source "$ZSH_FILES/hosts/ubuntu.zsh"

setopt ALL_EXPORT

#### default apps
TERMINAL="roxterm"
BROWSER="google-chrome"


# Golang!
GOPATH="$HOME/go"
eval $(go env)
PATH="$PATH:$GOPATH/bin"

## java config
JAVA_HOME="/usr/lib/jvm/jdk1.7.0"
M2_HOME="$HOME/Bundles/apache-maven-3.0.4"

# include JAVA stuff in PATH
PATH="$JAVA_HOME/bin:$PATH"

# Include programs installed in ~/Bundles in PATH
BUNDLES="$HOME/Bundles"
bundle-dir "$BUNDLES"
add-bundle-to-path "/opt/google"
add-bundle-to-path "/opt/bro"
PATH="$PATH:/opt/plan9/bin"

# LLVM / EMSCRIPTEN / CLANG
LLVM="$HOME/Bundles/clang+llvm-3.1-x86_64-linux-ubuntu_12.04/bin"

# GUI stuff
alias open="gnome-open"

#RVM
source "$HOME/.rvm/scripts/rvm"
PATH="$PATH:$HOME/.rvm/bin" # Add RVM to PATH for scripting

#VIRTUALENV Wrapper
WORKON_HOME="$HOME/.virtualenvs"
source /etc/bash_completion.d/virtualenvwrapper

# NPM packages in homedir
NPM_PACKAGES="$HOME/.npm-packages"

# Tell our environment about user-installed node tools
PATH="$NPM_PACKAGES/bin:$PATH"
# Unset manpath so we can inherit from /etc/manpath via the `manpath` command
unset MANPATH  # delete if you already modified MANPATH elsewhere in your config
MANPATH="$NPM_PACKAGES/share/man:$(manpath)"

# Tell Node about these packages
NODE_PATH="$NPM_PACKAGES/lib/node_modules:$NODE_PATH"

# Locations
win="/mnt/hgfs/winhome"
learnstreet="$win/Dropbox/External/New LS Files/Learn Street"

# PLAN9 UP IN THIS
PLAN9="/opt/plan9"

setopt no_ALL_EXPORT

#####
# Aliases
alias nomcopter="ssh justjake@nomcopter.com -p 484"
alias hosing="ssh justjake@nomcopter.com -p 484" #TODO: run the net command from kevin's homedir

#alias tmux because it won't 256 colors correclty
