#!/usr/bin/env sh

echo "checking if terminfo for $TERM needs to be patched..."
if infocmp $TERM | grep --quiet 'kbs=^[hH]' ; then
  DIR=`mktemp -d /tmp/patch-terminfo.XXXX`
  if [ $? -ne 0 ]; then
    echo "could not create a tempdir."
    exit 1
  fi
  cd $DIR
  echo "working in $DIR"

  echo "patching terminfo for '$TERM' to support nvim Ctrl-H"
  infocmp $TERM | sed 's/kbs=^[hH]/kbs=\\177/' > $TERM.ti
  tic $TERM.ti

  echo "success! cleaning up..."
  rm -rf $DIR
  echo "cleaned up."
  echo 'if this didnt work, you may need to set TERMINFO="$HOME/.terminfo"'
else
  echo "no patch needed"
fi
