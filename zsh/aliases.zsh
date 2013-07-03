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
[[ -f "$ZSH_FILES/hosts/$HOSTNAME.zsh" ]] && alias hostsettings="$EDITOR $ZSH_FILES/hosts/$HOSTNAME.zsh"
[[ -f "$ZSH_FILES/hosts/$HOSTNAME" ]] &&     alias hostsettings="$EDITOR $ZSH_FILES/hosts/$HOSTNAME"
alias globalsettings="$EDITOR ~/.zshrc"
alias aliases="$EDITOR $ZSH_FILES/aliases.zsh"

# commands
alias resource="source ~/.zshrc"
alias sasswatch="sass --watch stylesheets/source:stylesheets"
function middleman-dev {
    x-www-browser "http://localhost:4567" &
    middleman
}

# Paths
if [[ "$HOSTNAME" == *rescomp.berkeley.edu ]] ; then
    export SVNCODE="https://svn.rescomp.berkeley.edu/code"
    export SVNTMPL="https://svn.rescomp.berkeley.edu/marketing"
    export CODE="/usr/code/jitl/"
fi

goproj="$GOPATH/src/github.com/justjake/j3"

# rdesktop
alias remote="rdesktop -u just.jake -g 1280x768 remote.housing.berkeley.edu"

# SSH Hosts
alias hal="ssh jitl@hal.rescomp.berkeley.edu"
alias irc="ssh jitl@irc.housing.berkeley.edu -D 50000 -L 6667:irc.housing.berkeley.edu:6667"
alias tonic="ssh justjake@tonic.teton-landis.org"
alias star="ssh cs61a-zz@star.cs.berkeley.edu"
alias fstar="sftp cs61a-zz@star.cs.berkeley.edu"
alias nomcopter="ssh justjake@nomcopter.com -p 484"
alias stargate="ssh jitl@stargate.housing.berkeley.edu"
alias stargate="ssh -A -i ~/.ssh/id_rsa jitl@stargate.housing.berkeley.edu"

# tmux config: https://github.com/adnichols/tmux_setup
alias fixssh="source ~/bin/fixssh"


#### Rescomp Dev
for n in {1..15} ; do
    alias dev$n="ssh dev-www$n.rescomp.berkeley.edu"
done
# Databases
alias devdb='psql -h test-db -p 5433 rescomp'
#For dev-cc, ssh into hal then dev-cougar first.
#alias devcc='psql -h dev-sal -p 5432 cc'
alias testdb='psql -h test-db -p 5432 rescomp'
alias proddb='psql -h db rescomp'
# Dev util
alias apacherl='sudo /usr/local/etc/rc.d/apache22 restart;sleep 5;sudo /usr/local/etc/rc.d/apache22 status'
alias deverror='sudo /usr/bin/tail -f /var/log/httpd-error.log'
alias devaccess='sudo /usr/bin/tail -f /var/log/httpd-access.log'
#alias fixlogs='sudo /usr/local/etc/rc.d/syslog-ng restart'
alias websync='sudo svn export --force $SVNTMPL/webtree/ /usr/local/www/rescomp/docs/'


setopt NO_ALL_EXPORT
