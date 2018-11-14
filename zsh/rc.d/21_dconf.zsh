# Save and restore Gnome settings
DOTFILES_DCONF_ROOT="$HOME/.dotfiles/meta/linux/dconf"
dotfiles-dconf-dir-save () (
  set -e
  local dir="$1"
  if [[ -z "$dir" ]]; then
    echo "Usage: dotfiles-dconf-save /dir/to/settings/"
    exit 2
  fi

  local fname="$(basename "$dir")"
  local dname="$(dirname "$dir")"
  local store="$DOTFILES_DCONF_ROOT/$dname/$fname.gvariant"

  mkdir -p "$(dirname "$store")"
  dconf dump "$dir" > "$store"

  # Show what was created
  file "$store"
)

dotfiles-dconf-dir-load () (
  set -e
  local dir="$1"

  if [[ -z "$dir" ]]; then
    echo "Usage: dotfiles-dconf-load /dir/to/settings/"
    exit 2
  fi

  local fname="$(basename "$dir")"
  local dname="$(dirname "$dir")"
  local store="$DOTFILES_DCONF_ROOT/$dname/$fname.gvariant"

  dconf load "$dir" < "$store"
  echo "Loaded $store"
)

# The interesting dconf sections we want to save. Why not do all of
# them? Because there's a lot of lame shit we don't care about.
DOTFILES_DCONF_SECTIONS=(
# Shell is very useful. Also contains all extension settings
/org/gnome/shell/
# Eg, speed and tap-to-click
/org/gnome/desktop/peripherals/touchpad/
# Eg gtk theme, fonts, text scaling
/org/gnome/desktop/interface/
# File browser settings like icon size
/org/gnome/nautilus/
# No bell, tall windows plz
/org/gnome/terminal/
)

dotfiles-dconf-save () {
  rm -rv "$DOTFILES_DCONF_ROOT"
  for dir in "${DOTFILES_DCONF_SECTIONS[@]}"; do
    dotfiles-dconf-dir-save "$dir"
  done
}

dotfiles-dconf-load () {
  for dir in "${DOTFILES_DCONF_SECTIONS[@]}"; do
    dotfiles-dconf-dir-load "$dir"
  done
}

