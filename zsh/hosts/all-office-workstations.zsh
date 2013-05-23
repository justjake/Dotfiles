# Include standard prefix
PREFIX="$HOME/prefixes/workstation"
add-bundle-to-path "$PREFIX"

PLAN9="$PREFIX/usr/local/plan9port"
export PLAN9
PATH="$PATH:$PLAN9/bin"
export PATH

