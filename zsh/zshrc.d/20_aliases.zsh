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

# Settings shortcuts
alias hostsettings="$EDITOR $ZSH_FILES/hosts/$HOSTNAME.zsh"
[[ -f "$ZSH_FILES/hosts/$HOSTNAME" ]] && alias hostsettings="$EDITOR $ZSH_FILES/hosts/$HOSTNAME"
alias settings="$EDITOR ~/.zshrc"
alias settings_all="$EDITOR $ZSH_FILES"
alias vimrc="$EDITOR $DOTFILES/vimrc.after"
alias resource="source ~/.zshrc"


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

### Rescomp Dev hosts
for n in {1..15} ; do
    alias dev$n="ssh dev-www$n.rescomp.berkeley.edu"
done

# tmux config: https://github.com/adnichols/tmux_setup
alias fixssh="source ~/bin/fixssh"