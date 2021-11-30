#!/usr/bin/env bash
## osxdotz: Application installer (via brew-cask)
set -eu

## if $basedir is unset
if [ -z ${basedir+x} ]; then
  basedir=$(dirname "$(perl -MCwd=realpath -e "print realpath '$0'")")
  basedir=$(dirname "$basedir")
fi

source "$basedir/lib/dotz_helpers.sh"

## search here: https://github.com/caskroom/homebrew-cask/tree/master/Casks

## Apps to install
cask_apps=(
  # browsers
  google-chrome
  firefox
  tor-browser
  # editors
  bbedit
  visual-studio-code
  # system
  iterm2
  sloth
  coconutbattery
  lulu
  # filezilla     ## removed due to malware/adware
  # compression/crypto
  the-unarchiver
  keka
  veracrypt
  # multimedia
  vlc
  iina
  # deluge
  qbittorrent
  # webtorrent
  # soda-player
  handbrake
  # chat
  slack
  discord
  linphone
  # vm
  virtualbox
  virtualbox-extension-pack
  # misc
  android-file-transfer
  android-platform-tools
  steam
  google-earth-pro
)

## Quick Look plugins to install
cask_qlplugins=(
  betterzip       ## betterzipql no longer maintained (betterzip includes qlplugin)
  qlimagesize     ## adds image size and resolution
  qlvideo
  qlmarkdown      ## .md files
  qlcolorcode     ## source code files with syntax highlighting
  qlstephen       ## view plain text files without a file extension
  quicklook-json
#   quicknfo        ## .nfo files, seems to not be working as of v1.2 ??
  suspicious-package
)

## Fonts to install
cask_fonts=(
#   font-m-plus
#   font-clear-sans
#   font-roboto
)

## Specify the install location for cask apps
appdir="/Applications"

echo ""
echo "osxdotz::homebrew_cask_apps"

## Ensure homebrew is installed
dotz_homebrew_install_update

## Tap fonts
#brew tap caskroom/fonts

## Install apps
if [ ! -z ${cask_apps+x} ]; then
  echo "Installing cask apps..."
  brew install --cask --appdir="$appdir" ${cask_apps[@]}
fi

## Install qlplugins
if [ ! -z ${cask_qlplugins+x} ]; then
  echo "Installing Quick Look plugins..."
  brew install --cask ${cask_qlplugins[@]}
fi

## Install fonts
if [ ! -z ${cask_fonts+x} ]; then
  echo "Installing cask fonts..."
  brew install --cask ${cask_fonts[@]}
fi

brew cleanup
