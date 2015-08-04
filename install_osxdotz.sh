#!/usr/bin/env bash
## osxdotz: Main installer
set -eu  ## Exit immediately if a command exits with a non-zero status,
         ## treat unset variables as an error when substituting.

dotz_version="v1.04"

dotz_banner="
 ▒█████    ██████ ▒██   ██▒▓█████▄  ▒█████  ▄▄▄█████▓▒███████▒
▒██▒  ██▒▒██    ▒ ▒▒ █ █ ▒░▒██▀ ██▌▒██▒  ██▒▓  ██▒ ▓▒▒ ▒ ▒ ▄▀░
▒██░  ██▒░ ▓██▄   ░░  █   ░░██   █▌▒██░  ██▒▒ ▓██░ ▒░░ ▒ ▄▀▒░ 
▒██   ██░  ▒   ██▒ ░ █ █ ▒ ░▓█▄   ▌▒██   ██░░ ▓██▓ ░   ▄▀▒   ░
░ ████▓▒░▒██████▒▒▒██▒ ▒██▒░▒████▓ ░ ████▓▒░  ▒██▒ ░ ▒███████▒
░ ▒░▒░▒░ ▒ ▒▓▒ ▒ ░▒▒ ░ ░▓ ░ ▒▒▓  ▒ ░ ▒░▒░▒░   ▒ ░░   ░▒▒ ▓░▒░▒
  ░ ▒ ▒░ ░ ░▒  ░ ░░░   ░▒ ░ ░ ▒  ▒   ░ ▒ ▒░     ░    ░░▒ ▒ ░ ▒
░ ░ ░ ▒  ░  ░  ░   ░    ░   ░ ░  ░ ░ ░ ░ ▒    ░ synth░ ░ ░ ░ ░
    ░ ░        ░   ░    ░     ░        ░ ░             ░ ░    
                            ░                        ░        "

echo "$dotz_banner"
echo "osxdotz $dotz_version: beginning..."
sleep 4

export basedir=$(dirname "$(perl -MCwd=realpath -e "print realpath '$0'")")
echo "osxdotz basedir: $basedir"

## http://superuser.com/questions/789448/choosing-between-bashrc-profile-bash-profile-etc
# echo ""
# echo "Installing .bash_profile..."
# new_profile="$basedir/resources/.bash_profile"
# if [[ -e "$new_profile" ]]; then
#   if [[ -e "$HOME/.bash_profile" ]]; then
#     echo "$HOME/.bash_profile already exists. remove and run again."
#   else
#     echo "Copying: $new_profile => $HOME/.bash_profile"
#     cp "$new_profile" "$HOME/.bash_profile"
#   fi
# else
#   echo "$new_profile not found."
# fi

## Do it
scriptdir="$basedir/scripts"
sh "$scriptdir/gitconfig.sh"
sh "$scriptdir/dotfiles.sh"
sh "$scriptdir/homebrew.sh"
sh "$scriptdir/homebrew_cask_apps.sh"
sh "$scriptdir/filetype_associations.sh"
sh "$scriptdir/dotfiles.sh"
sh "$scriptdir/zsh.sh"
sh "$scriptdir/defaults.sh"
sh "$scriptdir/dock_icons.sh"

echo ""
echo "osxdotz: finished!"
echo "Restarting now before messing with stuff is STRONGLY recommended."
