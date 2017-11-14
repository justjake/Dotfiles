# from `man zshcontrib`:
#
# > By default, run-help is an alias for the man command, so this often fails when
# > the command word is a shell builtin or a user-defined function. By redefining
# > the run-help alias, one can improve the on-line help provided by the shell.
# >
# > To use the run-help function, you need to add lines something like the
# following to your .zshrc or equivalent startup file:
type run-help 2>&1 | grep "alias" > /dev/null && unalias run-help
autoload run-help
alias help=run-help
