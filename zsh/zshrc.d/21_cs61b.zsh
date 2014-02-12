export CS61B="$HOME/src/cs61b"

61b-note () {
    $EDITOR "${CS61B}/lectures/lecture_$(date --rfc-3339=date).java"
}
