# Homebrew.
export HOMEBREW_CASK_OPTS="--appdir=$HOME/Applications"

# Android.
export ANDROID_HOME="$HOME/Library/Android/sdk"
export PATH="$PATH:$ANDROID_HOME/platform-tools"
add-bundle-to-path "$ANDROID_HOME/tools"

# NodeJS
export PATH="$PATH:./node_modules/.bin"
