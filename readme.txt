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

dotfiles etc.:
  config files are symlinked using stow (https://www.gnu.org/software/stow/manual/stow.html)
  osxdotz/scripts/stow.sh
    define which stow 'packages' to install and how/where they get installed
  osxdotz/resources/stow/
    put your stow 'packages' here
    e.g. stuff to symlink directly into $HOME goes in the 'home' package (.bash_profile, .zshrc, ...)

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
