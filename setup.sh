#!/bin/bash
set -euo pipefail
IFS=$'\n\t'
shopt -s dotglob

source util_fns.sh

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null && pwd )"
cd "$DIR"
EDITOR="$(get_editor)"

function main {
  check_os "Darwin"
  sudo --validate
  copy_templates
  source "$HOME/.cfgrc" # loaded in copy_templates
  install_xcode_tools
  install_homebrew
  generate_brewfile
  install_homebrew_packages
  install_xcode
  prompt_for_fish
  install_fisherman_plugins
  link_fish_settings
  link_dotfiles
  link_launch_agents
  link_bin_files
  install_rust
  install_node
  git_init_templates
}

function copy_templates {
  step "Templates are present"
  cd "$DIR/templates"
  templates=$(find . -type f | sed "s|^\./||")
  for template in $templates; do
    if [ -e "$HOME/$template" ]; then
      echo "$HOME/$template already exists"
    elif [ "$(basename "$template")" == ".keep" ]; then
      mkdir -p "$(dirname "$HOME/$template")"
    else
      mkdir -p "$(dirname "$HOME/$template")"
      cp "$template" "$HOME/$template"
      eval $EDITOR "$HOME/$template"
    fi
  done
}

function install_xcode_tools {
  step "XCode command-line tools are present"
  if ! xcode-select -p; then
    xcode-select --install
  else
    echo "Already present."
  fi
}

function install_homebrew {
  step "Homebrew is present and up to date"
  if ! [ -x "$(command -v brew)" ]; then
    echo "Installing Homebrew"
    /usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
  else
    echo "Already installed, updating."
  fi
  brew update
}

function generate_brewfile {
  step "Brewfile is present and up to date"
  local_brewfile="$HOME/.Brewfile.local"
  shared_brewfile="$DIR/Brewfile"
  if [ $(grep -cFwf "$shared_brewfile" "$local_brewfile") -gt 0 ]; then
    echo "Local and shared Brewfiles have duplicate packages. Remove the following lines from one of the files:"
    grep -Fwf "$shared_brewfile" "$local_brewfile"
    exit 1
  fi
  cat "$shared_brewfile" "$local_brewfile" > "$HOME/.Brewfile"
  echo "Done."
}

function install_homebrew_packages {
  step "Homebrew packages are installed"
  cd "$DIR"
  brew bundle --global
  brew upgrade
  mas upgrade
}

function cleanup_homebrew_packages {
  step "Old Homebrew packages are cleaned up"
  brew cleanup
  echo "brew bundle cleanup --global"
  brew bundle cleanup --global
}

function install_xcode {
  step "Remaining Xcode first launch tasks are run"
  if xcodebuild -checkFirstLaunchStatus; then
    sudo xcodebuild -runFirstLaunch
  else
    echo "No remaining tasks."
  fi
}

function prompt_for_fish {
  step "Fish is set as the login shell"
  echo "Current login shell: $SHELL"
  if [[ ! "$SHELL" =~ "fish" ]]; then
    echo "Set the login shell to fish, re-open a terminal, and try again."
    exit 1
  fi
}

function install_fisherman_plugins {
  step "Fisherman plug-ins are installed"
  cd "$DIR/fish"
  mkdir -p "$HOME/.config/fish/functions"
  link_if_absent "$DIR/lib/fisherman/fisher.fish" "$HOME/.config/fish/functions/fisher.fish"
  link_if_absent "$DIR/fish/fishfile" "$HOME/.config/fish/fishfile"
  fish -c fisher
}

function link_fish_settings {
  step "Fish settings are present"
  fish "$DIR/fish/vars.fish"
  link_all_if_absent "$DIR/fish/functions" "$HOME/.config/fish/functions"
  link_all_if_absent "$DIR/fish/completions" "$HOME/.config/fish/completions"
  link_all_if_absent "$DIR/fish/conf" "$HOME/.config/fish/conf.d"
  fish -c fish_update_completions
}

function link_dotfiles {
  step "Dotfiles are linked"
  link_all_if_absent "$DIR/dotfiles" "$HOME"
}

function link_launch_agents {
  step "User LaunchAgents are linked"
  mkdir -p "$HOME/Library/LaunchAgents/"
  cd "$DIR/launch-agents"
  for agent in *; do
    copy_if_absent "$DIR/launch-agents/$agent" "$HOME/Library/LaunchAgents/$agent"
    chmod 644 "$HOME/Library/LaunchAgents/$agent"
    launchctl load -w "$HOME/Library/LaunchAgents/$agent"
  done
}

function link_bin_files {
  step "User bin files are linked"
  cd "$DIR/bin"
  if [ ! -e "$BIN_HOME" ]; then
    echo "creating $BIN_HOME"
    mkdir "$BIN_HOME"
  fi
  link_all_if_absent "$DIR/bin" "$BIN_HOME"
}

function install_rust {
  step "Rust is installed"
  if [ -d "$HOME/.cargo" ]; then
    echo "Already installed at $HOME/.cargo"
  else
    curl https://sh.rustup.rs -sSf | sh -s -- --no-modify-path
  fi
}

function install_node {
  step "Node is installed using nvm"
  if ! fish -c "nvm ls" | grep -q "current"; then
    fish -c "nvm use latest"
  fi
  fish -c "nvm ls" | grep current
}

function git_init_templates {
  step "All projects use latest git templates"
  bash -c "find $CODE_HOME -name .git -execdir git init -q \; ; true"
  echo "Done."
}

function find_broken_symlinks {
  step "No broken symlinks"
  find "$HOME" -path "$HOME/Library" -prune -o -path "$HOME/.Trash" -prune -o -type l ! -exec test -e {} \; -print
  if [[ $BIN_HOME/ != $HOME/* ]]; then
    find "$BIN_HOME" -type l ! -exec test -e {} \; -print
  fi
  echo "Done."
}

main
