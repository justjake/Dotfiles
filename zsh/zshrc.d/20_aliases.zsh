###
# aliases
###

# ls and grep differs in FreeBSD and Linux
if [[ FreeBSD == $(uname) || Darwin == $(uname) ]] ; then
        alias ls='ls -G'
else
        alias ls='ls --color'
        grep_options="--color=auto --exclude-dir='.svn'"
fi

# Show only the defined mailboxes when you open mutt
alias mutt="mutt -y"

# colored commands
for grep_type in grep fgrep egrep ; do
    alias $grep_type="$grep_type $grep_options"
done

# some more ls aliases
alias ll='ls -alF'
alias la='ls -A'
alias l='ls -CF'
alias LS='ls'

# directories, single-quoted for dynamic variables
alias prefix='cd $PREFIX; ls'
alias project='cd $PROJECT; ls; which git >/dev/null 2>&1 && git status'

# edit settings
alias hostsettings="$EDITOR $ZSH_FILES/hosts/$HOSTNAME.zsh"
[[ -f "$ZSH_FILES/hosts/$HOSTNAME" ]] && alias hostsettings="$EDITOR $ZSH_FILES/hosts/$HOSTNAME"
alias settings="$EDITOR ~/.zshrc"
alias aliases="$EDITOR $ZSH_FILES/aliases.zsh"
alias vimrc="$EDITOR $DOTFILES/vimrc.after"

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

function tmux-shared () {
    local socket_name="$1"
    tmux -S /tmp/"$socket_name" new-session 
    chmod 777 /tmp/"$socket_name"
    tmux -S /tmp/"$socket_name" attach
}

# rdesktop
alias remote="rdesktop -u just.jake -g 1280x768 remote.housing.berkeley.edu"

#### SSH 

alias unlock="ssh-add ~/.ssh/id_rsa.wopr"

typeset -A ssh_hosts
ssh_hosts=(
# rescomp
hal         "hal.rescomp.berkeley.edu"
irc         "irc.housing.berkeley.edu"
architect   "thearchitect.rescomp.berkeley.edu"
devbox      "dev-www14.rescomp.berkeley.edu"

# personal
tonic       "tonic.teton-landis.org"
nomcopter   "nomcopter.com"
)
for short in ${(k)ssh_hosts}; do
    alias $short="ssh $ssh_hosts[$short]"
done


ffmpeg-extract-audio() {
    local src="$1"
    local dest="$2"
    ffmpeg -i "$1" -acodec copy -vn "$2"
}


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

