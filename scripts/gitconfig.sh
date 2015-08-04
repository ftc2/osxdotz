#!/usr/bin/env bash
## osxdotz: git config
set -eu

## if $basedir is unset
if [ -z ${basedir+x} ]; then
  basedir=$(dirname "$(perl -MCwd=realpath -e "print realpath '$0'")")
  basedir=$(dirname "$basedir")
fi

source "$basedir/lib/dotz_helpers.sh"

echo ""
echo "osxdotz::gitconfig"

## defaults
git_user_name='ftc2'
git_user_email='ftc2@users.noreply.github.com'

echo ""
[[ $(dotz_prompt_yn "Do you want to configure git?" ) != 'yes' ]] && exit 0

if [[ -e "$HOME/.gitconfig" ]]; then
  echo ""
  echo "$HOME/.gitconfig already exists."
  [[ $(dotz_prompt_yn "Continue configuring git anyway?" ) != 'yes' ]] && exit 0
fi

echo ""
read -ep "Enter your git user.name (default: $git_user_name): "
git_user_name=${REPLY:-$git_user_name}
read -ep "Enter your git user.email (default: $git_user_email): "
git_user_email=${REPLY:-$git_user_email}

echo ""
set -x
git config --global user.name "$git_user_name"
git config --global user.email "$git_user_email"
git config --global credential.helper osxkeychain
git config --global color.ui true
## When push.default is set to 'matching', git will push local branches
## to the remote branches that already exist with the same name.
## Since Git 2.0, Git defaults to the more conservative 'simple'
## behavior, which only pushes the current branch to the corresponding
## remote branch that 'git pull' uses to update the current branch.
git config --global push.default simple
