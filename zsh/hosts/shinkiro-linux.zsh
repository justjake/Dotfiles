# Shinkiro is a Huawei Matebook X Pro, running Ubuntu 18.04

# I record settings needed to make the system usable here.
matebook_x_pro_setup () (
  # This will print each command as its run
	set -x

  sudo apt update

  # Install development tools
	sudo apt install \
		git \
    curl \
		build-essential \
    tree

  # Install popular programming languages
  sudo apt install ruby nodejs

	# Neovim stable from PPA, although it might be better to use the unstable version...
  # See https://github.com/neovim/neovim/wiki/Installing-Neovim
	sudo apt install software-properties-common
	sudo apt-add-repository ppa:neovim-ppa/stable
	sudo apt-get update
	sudo apt-get install neovim

	# You'll need to follow this guide to fiddle with sound:
	xdg-open 'https://aymanbagabas.com/2018/07/23/archlinux-on-matebook-x-pro.html#update-1---fix-sound'
	sudo apt install alsa-tools-gui
	hdajackretask

  # Set system clock using local time, instead of UTC time then calculate offset
  # Needed for dual-booting because Windows expects the system clock to be local time
  timedatectl set-local-rtc 1 --adjust-system-clock

  # Optional: enable experimental scaling in Wayland -- X11 only has whole number scaling (200%, 300%)
  # This works great for Wayland-native apps like Settings, but apps like
  # Firefox or Chrome that run in XWayland will be blurry.
  #
	# gsettings set org.gnome.mutter experimental-features "['scale-monitor-framebuffer']"

  ## Set up ZSH
  sudo apt install zsh
  chsh /bin/zsh
	# This is needed for snaps to if you `chsh zsh`
	echo "emulate sh -c 'source /etc/profile'" | sudo tee -a /etc/zsh/zprofile

	# Normal Gnome (instead of ubuntu "brown" gnome): https://itsfoss.com/vanilla-gnome-ubuntu/
	sudo apt install gnome-session             # Select from the gear on the login UI
  sudo update-alternatives --config gdm3.css # Use stock styles for the login UI
  # Need to remove the ubuntu dock extension because it conflicts with other extensions
  # This will disable the standard ubuntu login, beware
  sudo apt remove gnome-shell-extension-ubuntu-dock

  # Restore gnome shell settings
  dotfiles-dconf-load
)

# Normal settings
alias pbcopy="xclip -selection c"

if which nvim > /dev/null 2>&1; then
  alias vi=vim
  alias vim=nvim
fi
