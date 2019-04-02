# SH-COMPATIBLE

# a bundle is a UNIX prefix
# this prepends the bundle's directories to your various tool
# load paths, so they take precedence over system versions
add_bundle_to_path () {
    local bundle="$1"
    [ -d "$bundle/bin" ]            && export PATH="$bundle/bin:$PATH"
    [ -d "$bundle/bin/x64" ]        && export PATH="$bundle/bin/x64:$PATH"
    [ -d "$bundle/share/man" ]      && export MANPATH="$bundle/share/man:$MANPATH"
    [ -d "$bundle/lib" ]            && export LD_LIBRARY_PATH="$bundle/lib:$LD_LIBRARY_PATH"
    [ -d "$bundle/lib64" ]          && export LD_LIBRARY_PATH="$bundle/lib64:$LD_LIBRARY_PATH"
    [ -d "$bundle/lib/pkgconfig" ]  && export PKG_CONFIG_PATH="$bundle/lib/pkgconfig:$PKG_CONFIG_PATH"
    [ -d "$bundle/include" ]        && export C_INCLUDE_PATH="$bundle/include:$C_INCLUDE_PATH"
    # add sub folders like "usr"
    [ -d "$bundle/usr" ]            && add_bundle_to_path "$bundle/usr"
    # source bundle config if it exists
    [ -f "$bundle/bundle.rc" ]      && . "$bundle/bundle.rc"
}

# I like to use ~/bundles to store my personal software in
# its own directory. This is a good place for java, intellij,
# my custom tmux, etc
bundle_dir () {
    local BUNDLES="$1"
    local bundle
    if [ -d "$BUNDLES" ]; then
        for bundle in "$BUNDLES"/*; do
            add_bundle_to_path "$bundle"
        done
    else
        echo "$BUNDLES does not exist"
    fi
}

# wat
if [ $SHELL = /bin/zsh ] || [ $SHELL = /bin/bash ] ; then
    alias 'add-bundle-to-path'=add_bundle_to_path
    alias 'bundle-dir'=bundle_dir
fi

# This doesn't work on macOS and I don't even remember what it's supposed to do.
# Maybe run bundle_dir if any bundles are installed?
#
# DEFAULT_BUNDLES="$HOME/bundles"
# if [ -d "$DEFAULT_BUNDLES" ]; then
#   if [ -n "$(ls -A "$DEFAULT_BUNDLES")" ]; then
#     bundle_dir "$DEFAULT_BUNDLES" && echo "installed bundles in $DEFAULT_BUNDLES"
#   fi
# fi
