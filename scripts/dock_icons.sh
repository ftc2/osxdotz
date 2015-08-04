#!/usr/bin/env bash
## osxdotz: Set up Dock icons using https://github.com/kcrawford/dockutil
set -eu

## if $basedir is unset
if [ -z ${basedir+x} ]; then
  basedir=$(dirname "$(perl -MCwd=realpath -e "print realpath '$0'")")
  basedir=$(dirname "$basedir")
fi

source "$basedir/lib/dotz_helpers.sh"

echo ""
echo "osxdotz::dock_icons"

dotz_install_if_missing dockutil

## Dock icons (ordered left to right)
dock_icons=(
  /Applications/Firefox.app
  /Applications/Google\ Chrome.app
  /Applications/iTunes.app
  /Applications/Adobe\ Photoshop\ CS6/Adobe\ Photoshop\ CS6.app
  /Applications/Microsoft\ Office\ 2011/Microsoft\ Word.app
  /Applications/Microsoft\ Office\ 2011/Microsoft\ Excel.app
  /Applications/Linphone.app
  /Applications/Utilities/Terminal.app
  /Applications/Utilities/Activity\ Monitor.app
  /Applications/System\ Preferences.app
)

if [ ! -z ${dock_icons+x} ]; then
  echo ""
  echo "Setting up Dock icons..."
  dockutil --remove all
  for icon in "${dock_icons[@]}"; do
    dockutil --add "$icon"
  done
fi
