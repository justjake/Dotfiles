if [[ -f "$HOME/.atuin/bin/env" ]]; then
  . "$HOME/.atuin/bin/env"
  eval "$(atuin init zsh --disable-up-arrow)"
  alias history="atuin history list"
fi
