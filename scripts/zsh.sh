#!/usr/bin/env bash
## osxdotz: zsh setup (update zsh via homebrew, make zsh the default shell, install Oh My Zsh)
set -eu

## if $basedir is unset
if [ -z ${basedir+x} ]; then
  basedir=$(dirname "$(perl -MCwd=realpath -e "print realpath '$0'")")
  basedir=$(dirname "$basedir")
fi

source "$basedir/lib/dotz_helpers.sh"

echo ""
echo "osxdotz::zsh"

dotz_homebrew_install

echo ""
echo "Installing latest zsh from homebrew..."
brew install zsh

echo ""
echo "Setting default shell to $(command -v zsh)"
## chsh will only let you change your default shell to something listed in /etc/shells
## check if the new zsh is in /etc/shells and add it if it's not
grep -q -F "$(command -v zsh)" /etc/shells || command -v zsh | sudo tee -a /etc/shells
chsh -s "$(command -v zsh)" || :

echo ""
echo "Installing Oh My Zsh..."
if [ -d "$HOME/.oh-my-zsh" ]; then
  echo "You already have Oh My Zsh installed. You'll need to remove $HOME/.oh-my-zsh if you want to (re-)install"
else
  git clone --depth=1 https://github.com/robbyrussell/oh-my-zsh.git "$HOME/.oh-my-zsh"
  echo ""
  echo "Removing $HOME/.oh-my-zsh/custom so that it can be symlinked later..."
  rm -rf "$HOME/.oh-my-zsh/custom"
fi

# if [[ ! -e "$HOME/.zshrc" ]]; then
#   echo ""
#   echo "$HOME/.zshrc not found."
#   echo "Copying: Oh My Zsh template file ($HOME/.oh-my-zsh/templates/zshrc.zsh-template) to $HOME/.zshrc"
#   cp "$HOME/.oh-my-zsh/templates/zshrc.zsh-template" "$HOME/.zshrc"
# fi

# echo ""
# echo "Installing .zshrc..."
# new_zshrc="$basedir/resources/.zshrc"
# if [[ -e "$HOME/.zshrc" ]]; then
#   echo "$HOME/.zshrc already exists. remove and run again."
# else
#   if [[ -e "$new_zshrc" ]]; then
#     echo "Copying: $new_zshrc => $HOME/.zshrc"
#     cp "$new_zshrc" "$HOME/.zshrc"
#   else
#     echo "Copying: Oh My Zsh template file ($HOME/.oh-my-zsh/templates/zshrc.zsh-template) to $HOME/.zshrc"
#     cp "$HOME/.oh-my-zsh/templates/zshrc.zsh-template" "$HOME/.zshrc"
#   fi
# fi
