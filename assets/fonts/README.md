# Maple Mono NF CN

A customised build of [Maple Mono](https://github.com/subframe7536/maple-font) with Nerd Font and
Chinese glyphs. [`build.sh`](build.sh) pins the upstream tag and the build flags.

## Build locally

Requires `git`, `uv`, `zip`, and `shasum`.

```sh
assets/fonts/build.sh                 # pinned tag, output in ~/.cache/maple-font-build
assets/fonts/build.sh -o dist v7.8    # another tag, another output directory
assets/fonts/build.sh --show          # print the tag and flags without building
```

## Publish a new build

1. Change `DEFAULT_TAG` or `BUILD_FLAGS` in `build.sh`.
2. Commit and push.
3. Run the **fonts-release** workflow from the Actions tab.
4. Point the fonts entry of `home/.chezmoiexternal.toml` at the new asset URL and SHA-256.
