## osxdotz: Helper functions

## Check for and install homebrew
dotz_homebrew_install() {
  command -v brew >/dev/null || {
    echo 'Homebrew not found! Installing Homebrew...'
    ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
  }
}

dotz_homebrew_install_update() {
  dotz_homebrew_install
  brew update
  brew upgrade --all
  brew cleanup
}

dotz_install_if_missing() {
  dotz_homebrew_install
  command -v $1 >/dev/null || brew install $1
}

dotz_prompt_yn() {
    read -p "$1 [y/n]: "
    case $(echo $REPLY | tr ':upper:' ':lower:') in
        y|yes) echo "yes" ;;
        *)     echo "no" ;;
    esac
}
