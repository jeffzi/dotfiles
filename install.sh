#!/bin/sh

# Install remotely from single shell command
# Usage : sh -c "$(curl -fsSL https://gitlab.com/jeffzi/dotfiles/-/raw/main/install.sh)"

case "$OSTYPE" in
  darwin*)  echo "Installing Xcode Command Line Tools"; xcode-select --install 2> /dev/null ;; 
  linux*)   echo "Linux not supported!" ;;
  msys*)    echo "Windows not supported!" ;;
  cygwin*)  echo "Windows not supported!" ;;
  *)        echo "Unsupported OS: $OSTYPE" ;;
esac

set -e

if [ ! "$(command -v chezmoi)" ]; then
  bin_dir="$HOME/.local/bin"
  chezmoi="$bin_dir/chezmoi"
  if [ "$(command -v curl)" ]; then
    sh -c "$(curl -fsSL https://git.io/chezmoi)" -- -b "$bin_dir"
  elif [ "$(command -v wget)" ]; then
    sh -c "$(wget -qO- https://git.io/chezmoi)" -- -b "$bin_dir"
  else
    echo "To install chezmoi, you must have curl or wget installed." >&2
    exit 1
  fi
else
  chezmoi=chezmoi
fi

# exec: replace current process with chezmoi init
exec "$chezmoi" init --apply https://gitlab.com/jeffzi/dotfiles
