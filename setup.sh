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

echo "Running semi-attended steps first"

if [ "$(defaults read com.apple.Terminal.plist 'Default Window Settings')" != "Solarized Dark ansi" ]; then
  open "$DIR/lib/solarized/osx-terminal.app-colors-solarized/Solarized Dark ansi.terminal"
  echo "Set this terminal theme to default and option as meta (under the keyboard tab)"
  read -p "Press enter to continue "
fi

cd "$DIR/templates"
for template in *; do
  if [ -e "$HOME/$template" ]; then
    echo "$HOME/$template already exists"
  else
    cp "$template" "$HOME/$template"
    vi "$HOME/$template"
  fi
done

echo "All remaining steps are unattended"

cd "$DIR"
brew bundle

cd "$DIR/dotfiles"
for dotfile in *; do
  link_if_absent "$DIR/dotfiles/$dotfile" "$HOME/$dotfile"
done

cd "$DIR/bin"
if [ ! -e "$HOME/bin" ]; then
  echo "creating $HOME/bin"
  mkdir "$HOME/bin"
fi
for binfile in *; do
  link_if_absent "$DIR/bin/$binfile" "$HOME/bin/$binfile"
done

