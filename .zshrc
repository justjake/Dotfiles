####
#   Jake's .zshrc
#   <just.1.jake@gmail.com>
#   from mako's .zshrc
####

MANSECT=1:1p:8:2:3:3p:4:5:6:7:9:0p:n:l:o
TZ="America/Los_Angeles"
HISTFILE=$HOME/.zhistory-"`hostname`""
HISTSIZE=1000
SAVEHIST=1000
HOSTNAME="`hostname`"
PAGER='less'
#EDITOR='bbedit -uw'
#EDITOR='mate -w'


####
# Host-specific settings!
# IE, PATH
####
# . "$HOME/.shell/hosts/"`hostname`"
if [[ -h "$HOME/.shell/local" ]]; then
    . "$HOME/.shell/local"
else
    echo "No local settings found"
    echo "Please ln -s \$HOME/.shell/host/\$HOSTNAME \$HOME/.shell/local"
#    echo "This will be done for you at next run"

#    if [[ !( -r "$HOME/.shell/hosts/`hostname`.wasWarned" ) ]]; then
#        touch "$HOME/.shell/hosts/`hostname`.wasWarned"
#    else
#        rm "$HOME/.shell/hosts/`hostname`.wasWarned"
#        touch "$HOME/.shell/hosts/`hostname`"
#        ln -s "$HOME/.shell/host/`hostname`" "$HOME/.shell/local"
#    fi

fi

####
# ZSH colors
####
autoload colors zsh/terminfo
if [[ "$terminfo[colors]" -ge 8 ]]; then
	colors
fi
for color in BLACK RED GREEN YELLOW BLUE MAGENTA CYAN WHITE; do
	eval PR_LIGHT_$color='%{$terminfo[bold]$fg[${(L)color}]%}'
	eval PR_$color='%{$fg[${(L)color}]%}'
	(( count = $count + 1 ))
done

# sanity colors
# . $HOME/.shell/colors

####
# Prompt
####
PR_NO_COLOR="%{$terminfo[sgr0]%}"
PS1="${PR_LIGHT_BLACK}[$PR_LIGHT_BLUE%n${PR_LIGHT_BLACK}@$PR_NO_COLOR$PR_GREEN%m${PR_LIGHT_BLACK}:$PR_LIGHT_GREEN%2c${PR_LIGHT_BLACK}]$PR_NO_COLOR$PR_RED %(!.#.$)$PR_NO_COLOR "
RPS1="$PR_LIGHT_BLACK(%D{%m-%d %H:%M})$PR_NO_COLOR"

#LANGUAGE=
LC_ALL='en_US.UTF-8'
LANG='en_US.UTF-8'
LC_CTYPE=C
# DISPLAY=:0

unsetopt ALL_EXPORT

####
# Aliases
####
. $HOME/.shell/aliases
alias f=finger

# alias	=clear
stty erase ^H &>/dev/null
#bindkey "^[[3~" delete-char
#chpwd() {
#     [[ -t 1 ]] || return
#     case $TERM in
#     sun-cmd) print -Pn "\e]l%~\e\\"
#     ;;
#    *xterm*|screen|rxvt|(dt|k|E)term) print -Pn "\e]2;%~\a"
#    ;;
#    esac
#}

#chpwd

####
# Keybinds
####
autoload -U compinit
compinit
bindkey '^r' history-incremental-search-backward
bindkey "^[[5~" up-line-or-history
bindkey "^[[6~" down-line-or-history
bindkey "^[[H" beginning-of-line
bindkey "^[[1~" beginning-of-line
bindkey "^[[F"  end-of-line
bindkey "^[[4~" end-of-line
bindkey ' ' magic-space    # also do history expansion on space
bindkey '^I' complete-word # complete on tab, leave expansion to _expand

zstyle ':completion::complete:*' use-cache on
zstyle ':completion::complete:*' cache-path ~/.zsh/cache/$HOST

zstyle ':completion:*' list-colors ${(s.:.)LS_COLORS}
zstyle ':completion:*' list-prompt '%SAt %p: Hit TAB for more, or the character to insert%s'
zstyle ':completion:*' menu select=1 _complete _ignored _approximate
zstyle -e ':completion:*:approximate:*' max-errors 'reply=( $(( ($#PREFIX+$#SUFFIX)/2 )) numeric )'
zstyle ':completion:*' select-prompt '%SScrolling active: current selection at %p%s'
zstyle ':completion:*:processes' command 'ps -axw'
zstyle ':completion:*:processes-names' command 'ps -awxho command'

# outdated completion for Macports
# zstyle ':completion:*:portlist' $(port list | awk '{print $1}')
# zstyle ':completion:*:*:port:*' $(port list | awk '{print $1}')

# Completion Styles
zstyle ':completion:*:*:kill:*:processes' list-colors '=(#b) #([0-9]#)*=0=01;31'
# list of completers to use
zstyle ':completion:*::::' completer _expand _complete _ignored _approximate

# allow one error for every three characters typed in approximate completer
zstyle -e ':completion:*:approximate:*' max-errors \
    'reply=( $(( ($#PREFIX+$#SUFFIX)/2 )) numeric )'

# insert all expansions for expand completer
zstyle ':completion:*:expand:*' tag-order all-expansions
#
#NEW completion:
# 1. All /etc/hosts hostnames are in autocomplete
# 2. If you have a comment in /etc/hosts like #%foobar.domain,
#    then foobar.domain will show up in autocomplete!
zstyle ':completion:*' hosts $(awk '/^[^#]/ {print $2 $3" "$4" "$5}' /etc/hosts | grep -v ip6- && grep "^#%" /etc/hosts | awk -F% '{print $2}')
# formatting and messages
zstyle ':completion:*' verbose yes
zstyle ':completion:*:descriptions' format '%B%d%b'
zstyle ':completion:*:messages' format '%d'
zstyle ':completion:*:warnings' format 'No matches for: %d'
zstyle ':completion:*:corrections' format '%B%d (errors: %e)%b'
zstyle ':completion:*' group-name ''

# match uppercase from lowercase
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Z}'

# offer indexes before parameters in subscripts
zstyle ':completion:*:*:-subscript-:*' tag-order indexes parameters

# command for process lists, the local web server details and host completion
#zstyle ':completion:*:processes' command 'ps -o pid,s,nice,stime,args'
#zstyle ':completion:*:urls' local 'www' '/var/www/htdocs' 'public_html'
zstyle '*' hosts $hosts

# Filename suffixes to ignore during completion (except after rm command)
zstyle ':completion:*:*:(^rm):*:*files' ignored-patterns '*?.o' '*?.c~' \
    '*?.old' '*?.pro'
# the same for old style completion
#fignore=(.o .c~ .old .pro)

# ignore completion functions (until the _ignored completer)
zstyle ':completion:*:functions' ignored-patterns '_*'
zstyle ':completion:*:scp:*' tag-order \
   files users 'hosts:-host hosts:-domain:domain hosts:-ipaddr"IP\ Address *'
zstyle ':completion:*:scp:*' group-order \
   files all-files users hosts-domain hosts-host hosts-ipaddr
zstyle ':completion:*:ssh:*' tag-order \
   users 'hosts:-host hosts:-domain:domain hosts:-ipaddr"IP\ Address *'
zstyle ':completion:*:ssh:*' group-order \
   hosts-domain hosts-host users hosts-ipaddr
zstyle '*' single-ignored show

