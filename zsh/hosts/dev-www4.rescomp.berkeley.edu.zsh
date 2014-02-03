# FreeBSD devbox config

export PREFIX="$HOME/prefixes/freebsd"
export PATH="$PATH:$PREFIX/bin"

# virtualenv
export WORKON_HOME="$PREFIX/virtualenvs"
mkdir -p "$WORKON_HOME"
source "$(which virtualenvwrapper.sh)"

# bug-tool
which bug-helper.sh >/dev/null 2>&1 && source "$(which bug-helper.sh)"

export PROJECT="/usr/code/jitl"
export PERL_LOCAL_LIB_ROOT="$PERL_LOCAL_LIB_ROOT:/home/jitl/perl5";
export PERL_MB_OPT="--install_base /home/jitl/perl5";
export PERL_MM_OPT="INSTALL_BASE=/home/jitl/perl5";
export PERL5LIB="/home/jitl/perl5/lib/perl5:/usr/local/rescomp/lib/site_perl:$PERL5LIB";
export PATH="/home/jitl/perl5/bin:$PATH";
