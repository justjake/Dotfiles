#!/usr/bin/env bash

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
}
