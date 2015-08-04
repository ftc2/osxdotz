#!/usr/bin/env bash
## osxdotz: dotfiles
set -eu

## if $basedir is unset
if [ -z ${basedir+x} ]; then
  basedir=$(dirname "$(perl -MCwd=realpath -e "print realpath '$0'")")
  basedir=$(dirname "$basedir")
fi

source "$basedir/lib/dotz_helpers.sh"

echo ""
echo "osxdotz::dotfiles"

echo ""
[[ $(dotz_prompt_yn 'Do you want to clone dotfile repos?' ) != 'yes' ]] && exit 0

dotz_install_if_missing vcsh
dotz_install_if_missing myrepos

echo ""
echo "Cloning myrepos config..."
vcsh clone 'https://github.com/ftc2/mr.conf.git' 'mr'

echo ""
echo "Cloning/updating dotfile repos..."
mr update
