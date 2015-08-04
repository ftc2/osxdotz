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
if [[ -d "$HOME/.oh-my-zsh" ]]; then
  echo "You already have Oh My Zsh installed. You'll need to remove $HOME/.oh-my-zsh if you want to (re-)install"
else
  git clone --depth=1 https://github.com/robbyrussell/oh-my-zsh.git "$HOME/.oh-my-zsh"
  
  zshrctemplate="$HOME/.oh-my-zsh/templates/zshrc.zsh-template"
  echo ""
  echo "Copying Oh My Zsh zshrc template to $HOME/.zshrc"
  
  if [[ -e "$HOME/.zshrc" ]]; then
    zshrcbak="$HOME/zshrc.bak"
    echo ""
    echo "Existing $HOME/.zshrc found. Moving to $zshrcbak"
    if [[ -e "$zshrcbak" ]]; then
      echo "$zshrcbak already exists. Aborting."
      exit 0
    fi
    mv "$HOME/.zshrc" "$zshrcbak"
  fi
  
  cp "$zshrctemplate" "$HOME/.zshrc"

fi
