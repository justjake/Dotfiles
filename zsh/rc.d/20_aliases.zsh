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
typeset -A editor_aliases
editor_aliases=(
dotfiles        "~/.dotfiles"
zshrc           "~/.dotfiles/zshrc"
aliases         "~/.dotfiles/zsh/rc.d/20_aliases.zsh"
gotorc          "~/.dotfiles/zsh/rc.d/19_goto.sh"
vimrc           "~/.dotfiles/config/nvim"
nvimrc          "~/.dotfiles/config/nvim"
nvimdeps        "~/.local/share/nvim/lazy/"
gitrc           "~/.dotfiles/gitconfig"
sshconfig       "~/.ssh/config"
tmuxrc          "~/.dotfiles/tmux.conf"
wezrc           "~/.dotfiles/config/wezterm"

nodemods        "node_modules"
)

edit_alias_path () {
  if [[ -d "$1" ]] ; then
    ( cd "$1" && "$EDITOR" . )
  else
    ( cd "$(dirname "$1")" && "$EDITOR" "$1" )
  fi
  local exit_code=$?

  if [[ $exit_code != 0 ]] ; then
    echo "$@: exited $exit_code, not updating" >&2
    return $exit_code
  fi

  # If we just edited a zsh config file, re-source it.
  if [[ "$1" == "$ZSH_FILES"*.zsh || "$1" == "$ZSH_FILES"*.sh || "$1" == ~/.dotfiles/zshrc ]] ; then
    # Spawn new zsh shell to pick up changes
    # trying to `source ...` somehow breaks inside the function.
    echo "Replacing zsh process to pick up changes to $1..."
    exec zsh
  fi
}

for short in ${(k)editor_aliases}; do
    alias $short="edit_alias_path $editor_aliases[$short]"
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

alias markdown=glow
alias md=glow
alias tf=terraform

branch() {
  git co -b jake--$(date "+%Y-%m-%d")-${1:-$(date '+T%H-%M')}
}

long_env() {
  long_envs=("local" development staging production)
  for env in "${long_envs[@]}"; do
    if [[ "$env" = "$1"* ]] ; then
      echo "$env"
      return 0
    fi
  done

  echo "unknown short env: not a prefix of any [${long_envs}]: '$1'" > /dev/stderr
  return 2
}

long_region() {
  case "$1" in
    usw2)
      echo us-west-2
      return 0
      ;;
    use1)
      echo us-east-1
      return 0
      ;;
    euc1)
      echo eu-central-1
      return 0
      ;;
  esac

  echo "unknown short region: '$1'" > /dev/stderr
  return 0
}

alias k=kubectl
k-mz-foreach() {
  local contexts=(
    mz-dev-space-usw2-0001
    mz-dev-space-usw2-0002
    mz-dev-space-euc1-0001
    mz-stg-space-usw2-0001
    mz-prod-space-usw2-0001
    mz-prod-space-usw2-0002
    mz-prod-space-euc1-0001
  )

  for ctx in "${contexts[@]}" ; do
    local cmd=(--context="${ctx}" "$@")
    printf "\n# k ${cmd}\n"
    k "${cmd[@]}"
  done
}

alias -g nodes2="nodes -o 'custom-columns=NAME:.metadata.name,TYPE:.metadata.labels.node\.kubernetes\.io/instance-type',AWS:.spec.providerID,CREATED:.metadata.creationTimestamp --sort-by=.metadata.creationTimestamp"


alias binbash=/bin/bash

alias isodate='date -u +"%Y-%m-%dT%H:%M:%SZ"'
alias uuid='uuidgen | tr "[:upper:]" "[:lower:]" | { uuid="$(cat /dev/stdin)"; printf "$uuid" | pbcopy; printf "$uuid" }'

if [[ -e "$HOME/.claude/local/claude" ]] ; then
  alias claude="$HOME/.claude/local/claude"
fi
alias ni=pnpm

pbmap() {
  local x
  x=$(pbpaste | "$@")
  printf '%s' "$x" | tee /dev/stderr | pbcopy
}

pbstripnewline() {
  pbmap tr -d '\n'
}
