# Base16 Shell
BASE16_SHELL="$HOME/.config/base16-shell/"
if [ -n "PS1" ]; then
  if [ -s "$BASE16_SHELL/profile_helper.sh" ]; then
    eval "$("$BASE16_SHELL/profile_helper.sh")"
  fi
fi
