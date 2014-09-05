###
# aliases
###

alias sudo='sudo -E'

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
alias ll='ls -alFh'
alias la='ls -A'
alias l='ls -CF'

# ack-grep --> ack
if which ack-grep no-output; then
    alias ack=ack-grep
fi

# Settings shortcuts
typeset -A settings_files
settings_files=(
zshrc           "~/.zshrc"
hostsettings    "$ZSH_FILES/hosts/$HOSTNAME.zsh"
aliases         "$ZSH_FILES/rc.d/20_aliases.zsh"
zshall          "$ZSH_FILES"

# non-zsh
vimrc           "~/.vimrc"
sshconfig       "~/.ssh/config"
)
for short in ${(k)settings_files}; do
    alias $short="$EDITOR $settings_files[$short]"
done
[[ -f "$ZSH_FILES/hosts/$HOSTNAME" ]] && alias hostsettings="$EDITOR $ZSH_FILES/hosts/$HOSTNAME"
alias resource="source ~/.zshrc"


# rdesktop
alias remote="rdesktop -u just.jake -g 1280x768 remote.housing.berkeley.edu"

#### SSH
alias unlock="
    ssh-add ~/.ssh/id_rsa.wopr
    ssh -N stargate.housing.berkeley.edu
"

### Rescomp Dev hosts
for n in {1..15} ; do
    alias dev$n="ssh dev-www$n.rescomp.berkeley.edu"
done

typeset -A ssh_hosts
ssh_hosts=(
# rescomp
hal         "hal.rescomp.berkeley.edu"
irc         "irc.housing.berkeley.edu"
architect   "thearchitect.rescomp.berkeley.edu"
devbox      "dev-www14.rescomp.berkeley.edu"
stargate    "stargate.housing.berkeley.edu"
pitfall     "pitfall.rescomp.berkeley.edu"
test-db     "test-db.rescomp.berkeley.edu"
dev9        "dev9-forward"

# personal
tonic       "tonic.teton-landis.org"
armada      "armada.systems"
)
for short in ${(k)ssh_hosts}; do
    alias $short="ssh $ssh_hosts[$short]"
done


# tmux config: https://github.com/adnichols/tmux_setup
alias fixssh="source ~/bin/fixssh"
alias httpdlog="sudo tail -f /var/log/httpd-*"
alias path='readlink -e'

# aliasing for "op" to open files in GUI
# last in list we hit will be the alias
OPEN_PREFS_ORDER=(gnome-open kde-open xfce-open xdg-open)
for cmd in $OPEN_PREFS_ORDER; do
  which $cmd no-output && alias open=$cmd
done
