#!/bin/bash
set -euo pipefail
IFS=$'\n\t'
shopt -s dotglob

source util_fns.sh

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null && pwd )"
cd "$DIR"
EDITOR="$(get_editor)"

function main {
  sudo --validate
  link_templates
  source "$HOME/.cfgrc" # loaded in link_templates
  install_xcode_tools
  install_homebrew
  generate_brewfile
  install_homebrew_packages
  install_xcode
  prompt_for_fish
  install_fisherman_plugins
  link_fish_settings
  update_package_managers
  link_dotfiles
  link_launch_agents
  link_bin_files
  git_init_templates
}

function link_templates {
  step "Ensure templates are present"
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
  step "Ensure XCode command-line tools are present"
  if ! xcode-select -p; then
    xcode-select --install
  fi
}

function install_homebrew {
  step "Ensure Homebrew is present and up to date"
  if ! [ -x "$(command -v brew)" ]; then
    echo "Installing Homebrew"
    /usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
  fi
  brew update
}

function generate_brewfile {
  step "Generate Brewfile"
  cat "$DIR/Brewfile" "$HOME/.Brewfile.local" > "$HOME/.Brewfile"
  echo "Done."
}

function install_homebrew_packages {
  step "Ensure Homebrew packages are installed"
  cd "$DIR"
  brew bundle --global
  brew upgrade
  brew cask upgrade
  mas upgrade
  brew cleanup
}

function install_xcode {
  step "Run any remaining Xcode first launch tasks"
  if xcodebuild -checkFirstLaunchStatus; then
    sudo xcodebuild -runFirstLaunch
  fi
}

function update_package_managers {
  step "Ensure package managers are up to date"
  pip2 install --upgrade pip
  bash -c "pip2 list --outdated --format=freeze | grep -v '^\-e' | cut -d = -f 1  | xargs -n1 pip2 install -U; true"
  pip3 install --upgrade pip
  bash -c "pip3 list --outdated --format=freeze | grep -v '^\-e' | cut -d = -f 1  | xargs -n1 pip3 install -U; true"
  fish -c "nvm use latest; and npm update -g"
  gem update --system
  gem update
}

function prompt_for_fish {
  step "Check that fish is set as the login shell"
  echo "Current login shell: $SHELL"
  if [[ ! "$SHELL" =~ "fish" ]]; then
    echo "Set the login shell to fish, re-open a terminal, and try again."
    exit 1
  fi
}

function install_fisherman_plugins {
  step "Ensure fisherman plug-ins are installed"
  cd "$DIR/fish"
  mkdir -p "$HOME/.config/fish/functions"
  link_if_absent "$DIR/lib/fisherman/fisher.fish" "$HOME/.config/fish/functions/fisher.fish"
  link_if_absent "$DIR/fish/fishfile" "$HOME/.config/fish/fishfile"
  fish -c fisher
}

function link_fish_settings {
  step "Ensure fish settings are present"
  fish "$DIR/fish/vars.fish"
  fish "$DIR/fish/secret_vars.fish"
  link_all_if_absent "$DIR/fish/functions" "$HOME/.config/fish/functions"
  link_all_if_absent "$DIR/fish/completions" "$HOME/.config/fish/completions"
  link_all_if_absent "$DIR/fish/conf" "$HOME/.config/fish/conf.d"
}

function link_dotfiles {
  step "Ensure dotfiles are linked"
  link_all_if_absent "$DIR/dotfiles" "$HOME"
}

function link_launch_agents {
  step "Ensure user LaunchAgents are linked"
  mkdir -p "$HOME/Library/LaunchAgents/"
  cd "$DIR/launch-agents"
  for agent in *; do
    copy_if_absent "$DIR/launch-agents/$agent" "$HOME/Library/LaunchAgents/$agent"
    chmod 644 "$HOME/Library/LaunchAgents/$agent"
    launchctl load -w "$HOME/Library/LaunchAgents/$agent"
  done
}

function link_bin_files {
  step "Ensure bin executables are linked"
  cd "$DIR/bin"
  if [ ! -e "$BIN_HOME" ]; then
    echo "creating $BIN_HOME"
    mkdir "$BIN_HOME"
  fi
  link_all_if_absent "$DIR/bin" "$BIN_HOME"
}

function git_init_templates {
  step "Ensure all projects use latest git templates"
  bash -c "find $CODE_HOME -name .git -execdir git init \; ; true"
}

main
