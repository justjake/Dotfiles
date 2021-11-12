add-bundle-to-path /usr/local/opt/node@12
# . "$HOME/bundles/emsdk/emsdk_env.sh"
. "$HOME/.poetry/env"

# Also use node_modules
export PATH="$PATH:./node_modules/.bin"

export PATH="$PATH:/usr/local/go/bin"

if which nvim > /dev/null 2>&1; then
  alias vi=vim
  alias vim=nvim
fi

alias google-chrome="'/Applications/Google Chrome.app/Contents/MacOS/Google Chrome'"

# usage: copy something, then pbpaste | check-terraform
check-terraform() {
awk '{
  id=$1
  sub("^[^\\.]*\\.", "", id)
  sub("\\..*$", "", id)
  if (current_id == "") { current_id = id }
  if (id != current_id) {
    if (first_value != second_value) {
      print id " " current_id " "  name " " first_value " => " second_value
      has_changes = "true"
    }
    first_value = ""
    second_value = ""
    current_id=id
    name = ""
  }}
  /namespace:/ { namespace=$2 }
  /name:/ { name=$2 }
  /value:/ {
    first_value=$0
    second_value=$0
    sub("^[^\"]*\"", "\"", first_value)
    sub(" =>.*", "", first_value)

    sub(".* => ", "", second_value)
  }
  END {
    if (name && first_value != second_value) {
      has_changes = "true"
      print name " " first_value " => " second_value
    }

    if (has_changes == "") {
      print "Up to date!"
    }
  }'
}

with-github-token () {
  (
    set -e
    GITHUB_TOKEN=$(security find-generic-password -s github.token -w)
    set -x
    export GITHUB_TOKEN
    "$@"
  )
}

# Android
export ANDROID_HOME="$HOME/Library/Android/sdk"
export ANDROID_VERSION="28.0.3"
export PATH="${PATH}:${ANDROID_HOME}/platform-tools:${ANDROID_HOME}/tools:${ANDROID_HOME}/build-tools/${ANDROID_VERSION}"

export PATH="/usr/local/opt/terraform@0.11/bin:$PATH"


restart-bluetooth() (
set -e
echo "Restarting bluetooth service..."
blueutil -p 0 && sleep 1 && blueutil -p 1

echo "Waiting bluetooth service to be restored..."
until blueutil -p | grep "1" >/dev/null; do sleep 1; done

echo "Searching for devices not connected..."
devices=($(blueutil --paired | grep "not connected" | awk -F '[ ,]' '{print $2}'))
echo "Found ${#devices[@]} recently paired devices not connected"

for device in ${devices[@]}; do
    for retry in {1..2}; do
    	echo "Trying to connect to ${device} ..."
        if blueutil --connect ${device}; then break; fi
        echo "Failed to connect to ${device}"
        sleep 1
    done
  done

)

export FZF_DEFAULT_COMMAND='rg --files --hidden --follow --glob "!.git/*"'

eval "$(rbenv init -)"

# make the default installing to homedir by adding this to ~/.profile or similar
export HOMEBREW_CASK_OPTS="--appdir=$HOME/Applications"
