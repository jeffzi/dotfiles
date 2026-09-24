#!/usr/bin/env bash

set -euo pipefail

#==============================================================================
# Helpers
#==============================================================================

color() {
	local color_code="$1"
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

# The CLI lists accounts only once the desktop app shares them with it, and
# listing them never raises an unlock prompt.
op_connected() {
	[[ -n "$(op account list 2>/dev/null)" ]]
}

# chezmoi templates read secrets through `op`, so `chezmoi init --apply` fails
# on a machine where the CLI integration is still off.
wait_for_1password() {
	# Without this, a missing `op` reads as "not connected" forever.
	command -v op >/dev/null 2>&1 || error "1Password CLI (op) is not on PATH after installing it"

	if op_connected; then
		return
	fi

	[[ -t 0 ]] ||
		error "1Password CLI is not connected and there is no terminal to wait on. Enable Settings > Developer > Integrate with 1Password CLI in the 1Password app, then re-run."

	info "Sign in to the 1Password app, then enable Settings > Developer > Integrate with 1Password CLI"
	open -a /Applications/1Password.app || info "Could not open 1Password automatically; open it manually"

	until op_connected; do
		read -r -p "Press Enter once the 1Password CLI integration is enabled... " _
	done
}

prepare_darwin() {
	if ! command -v brew >/dev/null 2>&1; then
		info "Installing homebrew..."
		local brew_installer
		brew_installer=$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh) ||
			error "Failed to download Homebrew installer"
		/bin/bash -c "$brew_installer"
	fi

	local brew_env
	brew_env=$(/opt/homebrew/bin/brew shellenv) || error "brew shellenv failed"
	eval "$brew_env"

	info "Installing 1password..."
	brew install --quiet --cask 1password/tap/1password-cli 1password
	wait_for_1password
}

#==============================================================================
# Main
#==============================================================================

main() {
	local os
	os=$(uname | tr '[:upper:]' '[:lower:]')

	case "$os" in
	darwin*) prepare_darwin ;;
	linux*) error "Linux not supported!" ;;
	msys*) error "Windows not supported!" ;;
	cygwin*) error "Windows not supported!" ;;
	*) error "Unsupported OS: $os" ;;
	esac

	command -v chezmoi >/dev/null 2>&1 || {
		info "Installing chezmoi..."
		brew install chezmoi
	}

	# Bootstrap needs the current tree only, not the repository history.
	exec chezmoi init --depth 1 jeffzi --apply
}

main "$@"
