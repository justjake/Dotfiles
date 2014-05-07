if [[ $COLORTERM = "gnome-terminal" ]]; then
    TERM="xterm-256color"
fi
bundle-dir "$HOME/bundles"

PATH="$HOME/local/bin:$PATH"

JAVA_HOME="$HOME/bundles/jdk1.7.0_51"
