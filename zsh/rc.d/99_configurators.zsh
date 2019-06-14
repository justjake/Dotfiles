# Things it doesn't make sense to put in meta/install.sh

setup-go-with-vim () {
    if [ -n "$GOROOT" ] ; then
        # basic scripts
        echo "linking VIM integration from $GOROOT/misc/vim into ~/.janus"
        [ ! -e "$HOME/.janus/go-tools" ] && ln -s "$GOROOT/misc/vim" "$HOME/.janus/go-tools"
    else
        echo "Goroot unset, cannot link go-tools"
    fi

    # autocomplete
    echo "Installing gocode for autocomplete"
    go get -u github.com/nsf/gocode
    [ ! -e "$HOME/.janus/gocode" ] && ln -s "$GOROOT/src/pkg/github.com/nsf/gocode/vim" "$HOME/.janus/gocode"
}

# use office client setup for the current host
use-office-client () {
    pushd "$ZSH_FILES/hosts/" no-output
    ln -s "all-office-workstations.zsh" "`hostname`.zsh"
    popd no-output
}

use-host () {
  local other_host="$1"

	(
		pushd "$ZSH_FILES/hosts/" no-output
		if [[ -e "$other_host".zsh ]] ; then
			ln -sv "$other_host".zsh `hostname`.zsh
		elif [[ -e "$other_host" ]] ; then
			ln -sv "$other_host" `hostname`.zsh
		else
			echo "Host not found: $other_host" > /dev/stderr
			return 1
		fi
	)
}
