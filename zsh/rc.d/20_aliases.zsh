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
# alias la='ls -A'
alias l='ls -CF'

# ack-grep --> ack
if which ack-grep no-output; then
    alias ack=ack-grep
fi

# Settings shortcuts
typeset -A settings_files
settings_files=(
zshrc           "~/.dotfiles/zshrc"
aliases         "$ZSH_FILES/rc.d/20_aliases.zsh"
zshall          "$ZSH_FILES"
gotorc          "~/.dotfiles/zsh/rc.d/19_goto.sh"

# non-zsh
vimrc           "~/.dotfiles/vimrc"
nvimrc          "~/.dotfiles/config/nvim/init.vim"
gitrc           "~/.dotfiles/gitconfig"
sshconfig       "~/.ssh/config"
tmuxrc          "~/.dotfiles/tmux.conf"
)
for short in ${(k)settings_files}; do
    alias $short="$EDITOR $settings_files[$short]"
done
alias resource="source ~/.zshrc"

#### SSH
typeset -A ssh_hosts
ssh_hosts=(
# personal
tonic       "tonic.teton-landis.org"
armada      "armada.systems"
cc          "jitl@cc.internal"
sheilds     "jitl@shields"
)
for short in ${(k)ssh_hosts}; do
    alias $short="ssh $ssh_hosts[$short]"
done

# tmux config: https://github.com/adnichols/tmux_setup
alias fixssh="source ~/bin/fixssh"
# alias pydoc="pythom -m pydoc"

altify () {
    local name="$1"
    mv "$name".png alt/
    cp "/mnt/storage/To Import/cards/${name}-alt.png" "./$name.png"
}
alias httpdlog="sudo tail -f /var/log/httpd-*"
alias path='readlink -e'

# aliasing for "op" to open files in GUI
# last in list we hit will be the alias
OPEN_PREFS_ORDER=(gnome-open kde-open xfce-open xdg-open)
for cmd in $OPEN_PREFS_ORDER; do
  which $cmd no-output && alias open=$cmd
done

# count the uglified-gzipped-kb of files
# Usage:
#   min-gzip-fsize foo.js bar.js
#   curl http://example.com/some.js | min-gzip-fsize
min-gzip-fsize () {
  if [[ $# -gt 0  ]]; then
    cat "$@" | uglifyjs -m | gzip | wc -c | ruby -e 'printf "%.2fkb\n", gets.strip.to_f / 1024.0'
  else
    uglifyjs -m | gzip | wc -c | ruby -e 'printf "%.2fkb\n", gets.strip.to_f / 1024.0'
  fi
}

psf () {
  ps aux | egrep "^USER|$1"
}

e () {
  if [[ `is-e-running` == stopped ]]; then
    emacs --daemon
  fi
  emacsclient "$@"
}

is-e-running () {
  emacsclient -e '(ignore)' > /dev/null 2>&1
  local success="$?"
  if [[ $success == 0 ]]; then
    echo running
  else
    echo stopped
  fi
}

alias godocs="godoc"
alias e-quit="emacsclient -e '(kill-emacs)'"
alias e-daemon="emacs --daemon"
alias scrab="scrabble-solver"
alias ruboshit="bundle exec rubocop --auto-correct"
alias ezj="sudo ezjail-admin"
alias tpbcopy='tmux show-buffer | pbcopy'
alias :qa="exit"

# pgrep but show all output with ps
function pgrep() {
  ruby -- - "$@" <<'EOR'
require 'shellwords'
pids = `/usr/bin/pgrep #{ARGV.shelljoin}`.strip.split("\n")
exit 1 unless pids.any?
exec('ps', '-p', pids.join(','))
EOR
}

function confirm-rm () {
  local usage="Usage: $0 file [file...]
View file in PAGER, then ask to delete
  "
  local response

  if [ "$#" == 0 ]; then
    echo "$usage"
    return 2
  fi

  while (( $# )); do
    $PAGER "$1"
    read -r "Delete $1? [Y/n] " response
    response="${response,,}" # tolower
    if [[ "$response" =~ ^(yes|y| ) ]] || [[ -z "$response" ]]; then
      rm -vf "$1"
    fi
    shift
  done
}

which exa >/dev/null 2>&1 && alias ls="exa"

# List all imports of given go package
# https://dave.cheney.net/2014/09/14/go-list-your-swiss-army-knife
go-imports () {
  go list -f '{{ join .Imports "\n" }}' "$@"
}

go-nonstandard-imports () {
  go-imports "$@" | xargs go list -f '{{if not .Standard}}{{.ImportPath}}{{end}}'
}

repo () {
  local repo="$(basename "$1")"
  local owner="$(dirname "$1")"

  if [[ "$owner" == "." ]] ; then
    # default to me
    owner="justjake"
  fi

  if ! [[ -d "$HOME/src/$repo" ]]; then
    (
      set -ex
      mkdir -p "$HOME/src"
      cd "$HOME/src"
      git clone "git@github.com:$owner/$repo"
    )
  fi
  cd "$HOME/src/$repo"
  pwd
  ls
}

alias :q=exit

fix-uuid() {
  pbpaste | sed 's|\([a-z0-9]\{8\}\)\([a-z0-9]\{4\}\)\([a-z0-9]\{4\}\)\([a-z0-9]\{4\}\)|\1-\2-\3-\4-|' | tee /dev/stderr | pbcopy
}

unfix-uuid() {
  pbpaste | sed 's|-||g' | tee /dev/stderr | pbcopy
}

alias nfix="notion eslint --branch --fix ; notion prettier --branch"

if which nvim > /dev/null ; then
  alias vim=nvim
fi

if which rg > /dev/null ; then
  alias ag=rg
fi

markdown=glow
md=glow
tf=terraform
