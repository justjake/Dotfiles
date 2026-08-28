if command-exists scmpuff; then
  eval "$(scmpuff init -s)"

  scmpuff_status() {
    local cmd_output
    cmd_output="$(scmpuff status --filelist "$@")"

    local es=$?
    if [ $es -ne 0 ]; then
      return $es
    fi

    local files file name line
    local -i e=1 bytes=0 max_bytes=$((256 * 1024))
    {
      IFS= read -r files
      scmpuff_clear_vars

      local LC_ALL=C
      while IFS= read -r -d $'\t' file; do
        (( e > 999 )) && break
        name="e$e"
        (( bytes + ${#name} + ${#file} + 1 > max_bytes )) && break
        export "$name=$file"
        (( bytes += ${#name} + ${#file} + 1 ))
        (( e++ ))
      done < <(print -rn -- "$files"$'\t')

      while IFS= read -r line; do
        print -r -- "$line"
      done
    } < <(print -r -- "$cmd_output")
  }
fi
