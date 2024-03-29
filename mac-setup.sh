#!/bin/bash

# Exit on error
set -eo pipefail

ssh_key () {
if [ ! -f ~/.ssh/id_rsa ]; then
  if [ -z "$1" ]; then
    echo "pass the SSH name of this machine"
    return 1
  fi
  echo "creating ssh key"
  mkdir -p ~/.ssh
  (
  cd ~/.ssh
  set -x
  ssh-keygen -t rsa -b 4096 -C "$1"
  )
fi
}

clone_dotfiles () {
if [ ! -d ~/.dotfiles ]; then
  (set -x
  if ! git clone git@github.com:justjake/Dotfiles ~/.dotfiles ; then
    echo "*** clone failed. Do you need to add ~/.ssh/id_rsa.pub to your github account?"
    echo "    https://github.com/settings/keys"
    read -p "Press enter to try again, or type Ctrl-C to abort"
  fi
  )
fi
}

standard_dirs () {
mkdir -p ~/src
}

mac_dirs () {
mkdir -p ~/Applications
mkdir -p ~/Pictures/Screenshots
}

mac_brew_install () {
  if ! which brew > /dev/null ; then
    echo "Installing Homebrew"
    /usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
  fi

  if ! which brew > /dev/null ; then
    # Brew probably needs to be sourced
    eval "$(/opt/homebrew/bin/brew shellenv)"
  fi
}

mac_brew_cli () {
  (
  set -x
  brew install python
  brew install tmux
  brew install --HEAD neovim
  brew install ripgrep
  brew install jq
  brew install scmpuff
  brew install mas
  )
}

mac_brew_cask () {
  (
  set -x

  export HOMEBREW_CASK_OPTS="--appdir=$HOME/Applications"

  # Work-related essentials
  brew install --cask docker
  brew install --cask visual-studio-code
  brew install --cask iterm2
  brew install --cask viscosity  # VPN Client
  brew install --cask postico
  brew install --cask figma

  # Browsers
  brew install --cask firefox
  brew install --cask google-chrome

  # These are personal preference
  brew install --cask karabiner-elements
  brew install --cask spotify
  brew install --cask google-drive
  brew install --cask notion
  brew install --cask grandperspective # Directory size viewer, like Disk Daisy
  brew install --cask signal
  brew install --cask itsycal # Free/tiny bar calendar dingus
  )
}

mac_app_store () {
  mas install 497799835  # Xcode
  mas install 803453959  # Slack
  mas install 1514817810 # Poolside.fm
  mas install 425424353  # The Unarchiver
  mas install 540348655  # Monosnap
}

# stolen from https://github.com/mathiasbynens/dotfiles/blob/master/.osx
# also https://github.com/bkuhlmann/osx/blob/master/scripts/defaults.sh
mac_prefs () {
  printf "System - Expand save panel by default\n"
  defaults write NSGlobalDomain NSNavPanelExpandedStateForSaveMode -bool true

  printf "System - Avoid creating .DS_Store files on network volumes\n"
  defaults write com.apple.desktopservices DSDontWriteNetworkStores -bool true

  printf "Finder - Show filename extensions\n"
  defaults write NSGlobalDomain AppleShowAllExtensions -bool true

  printf "Finder - Show path bar\n"
  defaults write com.apple.finder ShowPathbar -bool true

  printf "Finder - Display full POSIX path as window title\n"
  defaults write com.apple.finder _FXShowPosixPathInTitle -bool true

  printf "Finder - Use list view in all Finder windows\n"
  defaults write com.apple.finder FXPreferredViewStyle -string "Nlsv"

  printf "Safari - Enable debug menu\n"
  defaults write com.apple.Safari IncludeInternalDebugMenu -bool true

  printf "Safari - Enable the Develop menu and the Web Inspector\n"
  defaults write com.apple.Safari IncludeDevelopMenu -bool true
  defaults write com.apple.Safari WebKitDeveloperExtrasEnabledPreferenceKey -bool true
  defaults write com.apple.Safari com.apple.Safari.ContentPageGroupIdentifier.WebKit2DeveloperExtrasEnabled -bool true

  printf "Safari - Add a context menu item for showing the Web Inspector in web views\n"
  defaults write NSGlobalDomain WebKitDeveloperExtras -bool true

  printf "Address Book - Enable debug menu\n"
  defaults write com.apple.addressbook ABShowDebugMenu -bool true

  printf "TextEdit - Open and save files as UTF-8 encoding\n"
  defaults write com.apple.TextEdit PlainTextEncoding -int 4
  defaults write com.apple.TextEdit PlainTextEncodingForWrite -int 4

  printf "Disk Utility - Enable debug menu\n"
  defaults write com.apple.DiskUtility DUDebugMenuEnabled -bool true
  defaults write com.apple.DiskUtility advanced-image-options -bool true


  printf "Printer - Expand print panel by default\n"
  defaults write NSGlobalDomain PMPrintingExpandedStateForPrint -bool true

  echo Set Help Viewer windows to non-floating mode
  defaults write com.apple.helpviewer DevMode -bool true

  echo Show the ~/Library folder
  chflags nohidden ~/Library

  echo Expand the following File Info panes:
  echo '“General”, “Open with”, and “Sharing & Permissions”'
  defaults write com.apple.finder FXInfoPanesExpanded -dict \
    General -bool true \
    OpenWith -bool true \
    Privileges -bool true

  echo "Enable Fast Key Repeat"
  defaults write -g ApplePressAndHoldEnabled -bool false
  defaults write -g KeyRepeat -int 1
}

metamove () {
  if [ -e ~/Applications/metamove.app ] ; then
    return 0
  fi

  (
    set -x
    cd ~/Applications
    curl -L 'https://github.com/jmgao/metamove/releases/download/v0.3.7/metamove-0.3.7.zip' -o metamove.zip
    unzip metamove.zip
    rm metamove.zip
  )
}

all () {
  ssh_key "$1"
  clone_dotfiles
  standard_dirs
  mac_dirs
  mac_brew_install
  mac_brew_cli
  metamove
  mac_brew_cask
  mac_app_store
  mac_prefs
}

if [[ -z "$*" ]]; then
  echo "pass a function name:"
  declare -F | sed 's/declare -f /  /g'
  echo "for all or ssh_setup, also pass the SSH key comment"
  echo "example: setup.sh ssh_key myname@newcompany.com"
  exit 1
fi

"$@"
