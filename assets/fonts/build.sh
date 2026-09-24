#!/usr/bin/env bash
#
# Build the customised Maple Mono NF CN family from upstream source.
#
# Usage: build.sh [-o output_dir] [upstream_tag]
#        build.sh --show
#
# stdout carries only `key=value` lines (tag, flags, zip, sha256) so a CI step
# can append it to $GITHUB_OUTPUT; all progress goes to stderr.

set -euo pipefail

# Bumping to an 8.x tag also means replacing --cn, which 8.0 deprecates in
# favour of `--cjk cn`.
readonly DEFAULT_TAG="v7.9"
readonly BUILD_FLAGS=(
	--cn
	--no-hinted
	--feat "cv01,cv02,cv07,cv33,cv34,cv62,cv64,ss01,ss03,ss05,ss07,ss08"
)

readonly UPSTREAM_REPO="https://github.com/subframe7536/maple-font"
# Upstream pins its dependencies against this interpreter in its own CI.
readonly PYTHON_VERSION="3.14"
readonly EXPECTED_TTF_COUNT=16
readonly DEFAULT_OUTPUT_DIR="${XDG_CACHE_HOME:-$HOME/.cache}/maple-font-build"

work_dir=""
current_step="startup"

log() {
	printf "=> %s\n" "$*" >&2
}

die() {
	printf "Error: %s\n" "$*" >&2
	exit 1
}

cleanup() {
	local status=$?
	if [[ -n "$work_dir" ]]; then
		rm -rf "$work_dir"
	fi
	if ((status != 0)); then
		printf "Error: failed during: %s\n" "$current_step" >&2
	fi
}

usage() {
	printf "Usage: %s [-o output_dir] [upstream_tag]\n       %s --show\n" "$0" "$0" >&2
}

show_config() {
	printf "tag=%s\n" "$1"
	printf "flags=%s\n" "${BUILD_FLAGS[*]}"
}

main() {
	local output_dir="$DEFAULT_OUTPUT_DIR"
	local tag="$DEFAULT_TAG"
	local tag_given=false
	local show=false

	while (($# > 0)); do
		case "$1" in
		-o)
			[[ -n "${2:-}" ]] || die "-o needs a directory"
			output_dir="$2"
			shift 2
			;;
		--show)
			show=true
			shift
			;;
		-h | --help)
			usage
			exit 0
			;;
		-*)
			usage
			die "unknown option: $1"
			;;
		*)
			[[ "$tag_given" == false ]] || die "only one upstream tag is accepted, got a second: $1"
			tag="$1"
			tag_given=true
			shift
			;;
		esac
	done

	# The tag ends up in a git ref, a file name, and CI step outputs.
	[[ "$tag" =~ ^[A-Za-z0-9][A-Za-z0-9._-]*$ ]] || die "invalid upstream tag: $tag"

	if [[ "$show" == true ]]; then
		show_config "$tag"
		exit 0
	fi

	local tool
	for tool in git uv zip shasum; do
		command -v "$tool" >/dev/null || die "$tool is required"
	done

	trap cleanup EXIT
	work_dir=$(mktemp -d)
	local src_dir="$work_dir/maple-font"

	current_step="clone of $UPSTREAM_REPO at $tag"
	log "Cloning maple-font $tag..."
	git clone --quiet --depth 1 --branch "$tag" "$UPSTREAM_REPO" "$src_dir" >&2

	current_step="dependency install"
	log "Installing build dependencies into a throwaway virtualenv..."
	uv venv --quiet --python "$PYTHON_VERSION" "$work_dir/venv" >&2
	uv pip install --quiet --python "$work_dir/venv/bin/python" \
		-r "$src_dir/requirements.txt" >&2

	# build.py fetches the CJK base fonts itself, so a failed download
	# surfaces here. It also shells out to tools its dependencies install
	# (ftcli), so the virtualenv's bin directory has to lead PATH.
	current_step="font build (includes the CJK base-font download)"
	log "Building with: ${BUILD_FLAGS[*]}"
	(
		cd "$src_dir" || die "cannot enter $src_dir"
		PATH="$work_dir/venv/bin:$PATH" python build.py "${BUILD_FLAGS[@]}"
	) >&2

	current_step="output check"
	local ttf_dir="$src_dir/fonts/NF-CN"
	local ttfs=()
	local ttf
	for ttf in "$ttf_dir"/MapleMono-NF-CN-*.ttf; do
		[[ -e "$ttf" ]] || continue
		ttfs+=("$ttf")
	done
	if ((${#ttfs[@]} != EXPECTED_TTF_COUNT)); then
		printf "Expected %d TTFs in %s, found %d:\n" \
			"$EXPECTED_TTF_COUNT" "$ttf_dir" "${#ttfs[@]}" >&2
		# bash 3.2 (stock macOS) treats an empty array as unbound under -u.
		if ((${#ttfs[@]} > 0)); then
			printf "  %s\n" "${ttfs[@]##*/}" >&2
		fi
		exit 1
	fi

	# The archive is staged and checksummed inside work_dir before being
	# moved to output_dir, so the checksum is always known before delivery.
	current_step="archive"
	local zip_name="MapleMono-NF-CN-$tag.zip"
	zip --quiet --junk-paths -X "$work_dir/$zip_name" "${ttfs[@]}" >&2

	current_step="checksum"
	local sha256
	sha256=$(shasum -a 256 "$work_dir/$zip_name")
	sha256="${sha256%% *}"

	current_step="move to $output_dir"
	mkdir -p "$output_dir"
	mv "$work_dir/$zip_name" "$output_dir/$zip_name"

	show_config "$tag"
	printf "zip=%s\n" "$output_dir/$zip_name"
	printf "sha256=%s\n" "$sha256"
}

main "$@"
