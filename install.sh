#!/bin/sh

#==============================================================================
# Helpers
#==============================================================================

set -eu

color() {
  color_code="$1"
  shift

  printf "\033[${color_code}m%s\033[0m\n" "$*" >&2
}

info() {
  color "0;36" "=> $*"
}

error() {
  color "0;31" "$@"
  exit 1
}

prepare_darwin() {
  if [ ! "$(command -v brew)" ]; then
    info "Installing homebrew..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  fi
  eval "$(/opt/homebrew/bin/brew shellenv)"

  info "Installing 1password..."
  brew install --quiet --cask 1password/tap/1password-cli 1password
  info "Log in now to the 1password app, enable settings/connect with 1Password CLI"
  open -a /Applications/1Password.app
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

if [ ! "$(command -v chezmoi)" ]; then
  bin_dir="$HOME/.local/bin"
  chezmoi="$bin_dir/chezmoi"
  info "Installing chezmoi..."
  if [ "$(command -v curl)" ]; then
    sh -c "$(curl -fsSL https://git.io/chezmoi)" -- -b "$bin_dir"
  elif [ "$(command -v wget)" ]; then
    sh -c "$(wget -qO- https://git.io/chezmoi)" -- -b "$bin_dir"
  else
    error "To install chezmoi, you must have curl or wget installed."
  fi
else
  chezmoi=chezmoi
fi

info "Running chezmoi..."
# exec: replace current process with chezmoi init
exec "$chezmoi" init jeffzi --apply
