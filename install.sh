#!/bin/sh

# Install remotely from single shell command
# Usage : sh -c "$(curl -fsSL https://gitlab.com/jeffzi/dotfiles/-/raw/main/install.sh)"

#==============================================================================
# Helpers
#==============================================================================

RED=$(tput setaf 1)
CYAN=$(tput setaf 6)
BOLD=$(tput bold)
RESET=$(tput sgr0)

info() {
    echo "${BOLD}${CYAN}=> $1${RESET}"
}

error() {
    echo "${BOLD}${RED}=> $1${RESET}"
    exit 1
}

prepare_darwin() {
    if [ ! "$(xcode-select -p &> /dev/null)" ]; then
        xcode-select --install
    fi

    until $(xcode-select --print-path &> /dev/null); do
      sleep 5;
    done

    if [ ! "$(command -v brew)" ]; then
        info "Installing homebrew..."
        /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    fi

    brew install --cask 1password/tap/1password-cli
}

OS=$(uname | tr '[:upper:]' '[:lower:]')
case $OS in
  darwin*)  prepare_darwin ;;
  linux*)   error "Linux not supported!" ;;
  msys*)    error "Windows not supported!" ;;
  cygwin*)  error "Windows not supported!" ;;
  *)        error "Unsupported OS: $OS" ;;
esac


#==============================================================================
# Chezmoi
#==============================================================================

set -e

info "Init chezmoi"

if [ ! "$(command -v chezmoi)" ]; then
  bin_dir="$HOME/.local/bin"
  chezmoi="$bin_dir/chezmoi"
  if [ "$(command -v curl)" ]; then
    sh -c "$(curl -fsSL https://git.io/chezmoi)" -- -b "$bin_dir"
  elif [ "$(command -v wget)" ]; then
    sh -c "$(wget -qO- https://git.io/chezmoi)" -- -b "$bin_dir"
  else
    error "To install chezmoi, you must have curl or wget installed." >&2
  fi
else
  chezmoi=chezmoi
fi

# exec: replace current process with chezmoi init
exec "$chezmoi" init --apply https://gitlab.com/jeffzi/dotfiles
