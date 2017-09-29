eval "$(rbenv init -)"
eval "$(nodenv init -)"

export GOPATH="$HOME/src/golang"
export PATH="$PATH:${GOPATH//://bin:}/bin"
export PATH="/usr/local/sbin:$PATH"

# swag
# https://github.com/micha/resty
# source "$HOME/bin/resty" # <-- was causing errors

alias a='cd ~/src/airbnb; ls'
alias p='cd ~/src/phoenix; ls'
alias c='cd ~/src/chef; ls'
alias rc='cd ~/src/codenames/redux-codenames; ls'
# alias n='nesh'
alias d='cd ~/src/deployboard; ls'
alias vboxrestart='sudo /Library/StartupItems/VirtualBox/VirtualBox restart'
alias jsc='env NODE_NO_READLINE=1 rlwrap -p Green -S "node >>> " node'
alias prodrc='ssh jake_teton-landis@rc1.musta.ch'
alias logstash-connect='ssh jake_teton-landis@bastion1.musta.ch -L 9200:i-bf8365ed.inst.aws.airbnb.com:9200'
alias migrate="bundle exec rake db:migrate"
function push-gem {
  scp $1 jake_teton-landis@geminabox-internal.aws.airbnb.com:~ && \
    ssh jake_teton-landis@geminabox-internal.aws.airbnb.com "add_gem.rb $1"
}

# lol
# type "fuck" to correct errors
alias fuck='eval $(thefuck $(fc -ln -1 | tail -n 1)); fc -R'

# torch, a lua for science
export LUA_PATH='/Users/jake_teton-landis/.luarocks/share/lua/5.1/?.lua;/Users/jake_teton-landis/.luarocks/share/lua/5.1/?/init.lua;/Users/jake_teton-landis/bundles/torch/install/share/lua/5.1/?.lua;/Users/jake_teton-landis/bundles/torch/install/share/lua/5.1/?/init.lua;./?.lua;/Users/jake_teton-landis/bundles/torch/install/share/luajit-2.1.0-alpha/?.lua;/usr/local/share/lua/5.1/?.lua;/usr/local/share/lua/5.1/?/init.lua'
export LUA_CPATH='/Users/jake_teton-landis/.luarocks/lib/lua/5.1/?.so;/Users/jake_teton-landis/bundles/torch/install/lib/lua/5.1/?.so;./?.so;/usr/local/lib/lua/5.1/?.so;/usr/local/lib/lua/5.1/loadall.so'
export PATH=/Users/jake_teton-landis/bundles/torch/install/bin:$PATH
export LD_LIBRARY_PATH=/Users/jake_teton-landis/bundles/torch/install/lib:$LD_LIBRARY_PATH
export DYLD_LIBRARY_PATH=/Users/jake_teton-landis/bundles/torch/install/lib:$DYLD_LIBRARY_PATH

# CUDA, a thing for things
export PATH=/Developer/NVIDIA/CUDA-7.0/bin:$PATH
export DYLD_LIBRARY_PATH=/Developer/NVIDIA/CUDA-7.0/lib:$DYLD_LIBRARY_PATH

# query optica for role
optica-fetch () {
  curl -s http://optica.d.musta.ch/\?role\=$@
}

optica-fetch-exact () {
  optica-fetch '^'$@'$'
}

# stream in an Optica JSON, get out a whitespace ceperated list of
# hostname role branch
optica-to-table () {
  jq -r '.nodes[] | [.hostname, .role, .branch] | @tsv' | column -t
}

nodes-like () {
  optica-fetch $@ | optica-to-table
}

nodes () {
  optica-fetch-exact $@ | optica-to-table
}

# expects STDIN containing optica talbe info
ssh-first () {
  local first="$(head -n 1)"
  ssh-node ${=first}
}

ssh-node () {
  local node="$1"
  local role="$2"
  local branch="$3"

  local host="${node}.inst.aws.airbnb.com"

  echo "id:     $node"
  echo "role:   $role"
  echo "branch: $branch"
  echo ">> ssh ${host}"
  echo "$host" | xargs -o ssh
}

ssh-to () {
  nodes $@ | ssh-first
}

# nvm use v4 --delete-prefix

export EDITOR="nvim"
alias vim=nvim
alias vi=/usr/local/bin/vim
export I_AM_AN_AIRLAB_DEVELOPER="haha hells yes"

export NVIM_LISTEN_ADDRESS="$HOME/.vim/sockets/vim-zsh-$$.sock"
