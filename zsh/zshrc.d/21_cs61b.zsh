export CS61B="$HOME/src/cs61b"
alias 61b="ssh cs61b-hg@hive4.cs.berkeley.edu"

61b-note () {
    $EDITOR "${CS61B}/lectures/lecture_$(date --rfc-3339=date).java"
}
