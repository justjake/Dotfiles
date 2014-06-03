### ZSH functions and utilities

# Stifle all output from a command. Postfix operator.
# SOME COMMAND no-output
alias -g no-output=">/dev/null 2>&1"

function command-exists {
    command -v "$1" no-output
}

# directory containing the script that invokes this function
# this-script-dir --> '/home/jitl/bin'
function this-script-dir {
    echo "$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
}

# expands a string with Bash/ZSH substitutions in it
# expand-string 'hello $USER' --> "hello jitl"
function expand-string {
    eval echo "$1"
}
