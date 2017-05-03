#!/usr/bin/env bash
## osxdotz: Install Homebrew and desired packages
set -eu

## if $basedir is unset
if [ -z ${basedir+x} ]; then
  basedir=$(dirname "$(perl -MCwd=realpath -e "print realpath '$0'")")
  basedir=$(dirname "$basedir")
fi

source "$basedir/lib/dotz_helpers.sh"

## Homebrew packages to install
## search here http://braumeister.org/
brew_packages=(
  watch
  wget
  git
  jhead
  exiftool
  md5deep
  imgur-screenshot
  youtube-dl
  qpdf
)

## Untapped homebrew formulae to install
## can be local paths or URLs to formulae
formula_basedir="$basedir/resources/homebrew_formulae"
untapped_brew_packages=(
#   "$formula_basedir/imgur-screenshot.rb"
)

echo ""
echo "osxdotz::homebrew"

## Ensure homebrew is installed
dotz_homebrew_install_update

## Install the packages

if [ ! -z ${brew_packages+x} ]; then
  echo ""
  echo "Installing homebrew packages..."
  brew install ${brew_packages[@]}
fi

if [ ! -z ${untapped_brew_packages+x} ]; then
  echo ""
  echo "Installing untapped homebrew packages..."
  for brew_pkg in "${untapped_brew_packages[@]}"; do
    brew install --HEAD "$brew_pkg"
  done
fi
