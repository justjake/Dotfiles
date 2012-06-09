###
# aliases
###
setopt ALL_EXPORT
# ls differs in FreeBSD and Linux
if [[ FreeBSD == $(uname) || Darwin == $(uname) ]] ; then
        alias ls='ls -G'
else
        alias ls='ls --color'
fi

# Show only the defined mailboxes when you open mutt
alias mutt="mutt -y"

# colored commands
alias grep='grep --color=auto'
alias fgrep='fgrep --color=auto'
alias egrep='egrep --color=auto'

# some more ls aliases
alias ll='ls -alF'
alias la='ls -A'
alias l='ls -CF'

# directories
alias prefix="cd $PREFIX"

# edit settings
alias hostsettings="$EDITOR $ZSH_FILES/hosts/$HOSTNAME"
alias globalsettings="$EDITOR ~/.zshrc"
alias aliases="$EDITOR $ZSH_FILES/aliases.zsh"

# logs
alias deverror="tail -f ~/.dev-www10-httpd-error.log"

# hosts
alias star="ssh cs61a-zz@star.cs.berkeley.edu"
alias fstar="sftp cs61a-zz@star.cs.berkeley.edu"

# commands
alias resource="source ~/.zshrc"
alias sasswatch="sass --watch stylesheets/source:stylesheets"
setopt NO_ALL_EXPORT
