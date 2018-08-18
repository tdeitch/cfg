#!/bin/bash
set -euo pipefail
IFS=$'\n\t'
shopt -s dotglob

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null && pwd )"

function link_if_absent() {
  if [ ! -e "$2" ]; then
    ln -s "$1" "$2"
    echo "linked $1 to $2"
  elif [ "$(readlink $2)" = "$1" ]; then
    echo "link to $2 already exists"
  else
    echo "failure linking $1 to $2"
    exit 1
  fi
}

echo "Ensure Solarized dark is installed"
if [ "$(defaults read com.apple.Terminal.plist 'Default Window Settings')" != "Solarized Dark ansi" ]; then
  open "$DIR/lib/solarized/osx-terminal.app-colors-solarized/Solarized Dark ansi.terminal"
  echo "Set this terminal theme to default and option as meta (under the keyboard tab)"
  read -p "Press enter to continue "
fi

echo "Ensure templates are present"
cd "$DIR/templates"
for template in *; do
  if [ -e "$HOME/$template" ]; then
    echo "$HOME/$template already exists"
  else
    cp "$template" "$HOME/$template"
    vi "$HOME/$template"
  fi
done

echo "Ensure Homebrew is present"
if ! [ -x "$(command -v brew)" ]; then
  echo "Installing Homebrew"
  /usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
fi

echo "Ensure Homebrew packages are installed"
cd "$DIR"
brew bundle

echo "Ensure fisherman plug-ins are installed"
cd "$DIR/fish"
link_if_absent "$DIR/lib/fisherman/fisher.fish" "$HOME/.config/fish/functions/fisher.fish"
fish -c "fisher ls" | grep -q '^z$' || fish -c "fisher z"

echo "Ensure fish variables are set"
fish "$DIR/fish/vars.fish"

echo "Ensure fish functions are present"
cd "$DIR/fish/functions"
for fn in *; do
  link_if_absent "$DIR/fish/functions/$fn" "$HOME/.config/fish/functions/$fn"
done

echo "Ensure secret fish variables are set"
fish "$DIR/fish/secret_vars.fish"

echo "Ensure dotfiles are linked"
cd "$DIR/dotfiles"
for dotfile in *; do
  link_if_absent "$DIR/dotfiles/$dotfile" "$HOME/$dotfile"
done

echo "Ensure bin executables are linked"
cd "$DIR/bin"
if [ ! -e "$HOME/bin" ]; then
  echo "creating $HOME/bin"
  mkdir "$HOME/bin"
fi
for binfile in *; do
  link_if_absent "$DIR/bin/$binfile" "$HOME/bin/$binfile"
done

