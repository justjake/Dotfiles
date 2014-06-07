# SH-COMPATIBLE

# a bundle is a UNIX prefix
# this prepends the bundle's directories to your various tool
# load paths, so they take precedence over system versions
add-bundle-to-path () {
    local bundle="$1"
    [ -d "$bundle/bin" ] && export PATH="$bundle/bin:$PATH"
    [ -d "$bundle/share/man" ] && export MANPATH="$bundle/share/man:$MANPATH"
    [ -d "$bundle/lib" ] && export LD_LIBRARY_PATH="$bundle/lib:$LD_LIBRARY_PATH"
    [ -d "$bundle/lib64" ] && export LD_LIBRARY_PATH="$bundle/lib64:$LD_LIBRARY_PATH"
    [ -d "$bundle/lib/pkgconfig" ] && export PKG_CONFIG_PATH="$bundle/lib/pkgconfig:$PKG_CONFIG_PATH"
    [ -d "$bundle/include" ] && export C_INCLUDE_PATH="$bundle/include:$C_INCLUDE_PATH"

    # add sub folders like "usr"
    [ -d "$bundle/usr" ] && add-bundle-to-path "$bundle/usr"
}

# I like to use ~/bundles to store my personal software in
# its own directory. This is a good place for java, intellij,
# my custom tmux, etc
bundle-dir () {
    local BUNDLES="$1"
    local bundle
    if [ -d "$BUNDLES" ]; then
        for bundle in "$BUNDLES"/*; do
            add-bundle-to-path $bundle
        done
    else
        echo "$BUNDLES does not exist"
    fi
}

DEFAULT_BUNDLES="$HOME/bundles"
[ -d "$DEFAULT_BUNDLES" ] && bundle-dir "$DEFAULT_BUNDLES"
