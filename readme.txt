-== osxdotz readme ==-

v1.04

before you start:
  install xcode
    agree to the xcode license (sudo xcodebuild -license)

then, take a look at the following and edit what you want:

main installer:
  osxdotz/install_osxdotz.sh
    just take a quick look to see what's going on.
      comment out any of the main components you're not interested in.
      run this when you're ready to go.

git config:
  osxdotz/gitconfig.sh
    interactively configures git

dotfiles etc.:
  osxdotz/dotfiles.sh
    dotfiles are managed using `vcsh` (https://github.com/RichiH/vcsh/) and
      `myrepos` (http://myrepos.branchable.com/)
    a vcsh repo containing a myrepos config is first cloned.
    this myrepos config describes git and vcsh repos (each containing a set of dotfiles)
      to be cloned using myrepos.

homebrew:
  osxdotz/scripts/homebrew.sh
    specify which homebrew packages to install
  osxdotz/scripts/homebrew_cask_apps.sh
    specify which homebrew-cask apps to install

filetype associations:
  set filetype associations using `duti` (http://www.duti.org)
  osxdotz/resources/filetype_associations/
    you can edit and create .duti files in there.
    take a look at the files already in there for syntax.
    all of the .duti configs in that directory will be applied when you run osxdotz.

zsh:
  osxdotz/scripts/zsh.sh
    update zsh via homebrew, make zsh the default shell, install Oh My Zsh

osx defaults:
  osxdotz/scripts/defaults.sh
    this is a big one. go through it and edit it to your liking.

dock icons:
  osxdotz/scripts/dock_icons.sh
    set up your dock icons using `dockutil` (https://github.com/kcrawford/dockutil)

Terminal.app themes:
  osxdotz/resources/terminal_themes/
    i was writing a script to load all themes in that dir, but it seems like gatekeeper
      or whatever didn't allow them to be loaded because they are from an 'unknown 
      developer'.  disabling gatekeeper would allow it to work, but for now, i just got
      rid of this feature.  maybe i'll fix it in a future version.
