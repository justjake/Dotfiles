export CS61B="$HOME/src/cs61b"

61b-note () {
    $EDITOR "${CS61B}/lectures/lecture_$(date --rfc-3339=date).java"
}

if [[ $(hostname) = hive*.CS.Berkeley.EDU ]]; then
    source "${ZSH_FILES}/hosts/all-hives.CS.Berkeley.EDU.zsh"
fi

if [[ ${USER} = cs* ]]; then 
    # the following command causes errors :(
    # you've tried it before :O
    #
    # source "$HOME/.bash_profile"
fi
