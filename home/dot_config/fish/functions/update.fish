function update -d "Upgrade Homebrew, App Store apps, Rust, uv tools, npm globals and fish plugins"
    # `chezmoi apply` only installs what is missing; every upgrade lives here.
    set -l steps brew mas rust uv npm fisher

    if set -q argv[1]
        if test (count $argv) -eq 1; and contains -- $argv[1] -h --help
            printf '%s\n' \
                "Usage: update" \
                "" \
                "Upgrades every installed tool, in this order:" \
                "  brew    Homebrew formulae and casks, then cleanup" \
                "  mas     Mac App Store apps" \
                "  rust    the Rust stable toolchain" \
                "  uv      every uv tool (hererocks included)" \
                "  npm     the npm globals in node-tools.txt; pinned versions stay pinned" \
                "  fisher  fish plugins" \
                "" \
                "A step whose tool is missing is skipped. A failed step does not stop" \
                "the others; update returns 1 when any step failed."
            return 0
        end
        echo "Usage: update [--help]" >&2
        return 1
    end

    set -l failed
    for step in $steps
        set -l requires
        switch $step
            case brew
                set requires brew
            case mas
                set requires mas
            case rust
                set requires rustup
            case uv
                set requires uv
            case npm
                set requires npm chezmoi
            case fisher
                set requires fisher
        end

        set -l missing
        for cmd in $requires
            type -q $cmd; or set -a missing $cmd
        end
        if set -q missing[1]
            echo "update: skipping $step, not installed: $missing" >&2
            continue
        end

        set_color cyan
        echo "=> $step"
        set_color normal

        switch $step
            case brew
                brew update; and brew upgrade; and brew cleanup
            case mas
                mas upgrade
            case rust
                rustup update stable
            case uv
                uv tool upgrade --all
            case npm
                __update_npm_globals
            case fisher
                fisher update
        end
        or set -a failed $step
    end

    if set -q failed[1]
        set_color red
        echo "update: failed steps: $failed" >&2
        set_color normal
        return 1
    end
end

# Reinstalls each entry of node-tools.txt as written: an unpinned name moves to
# its latest release, a pinned `name@version` stays at that version.
function __update_npm_globals
    set -l source_dir (chezmoi source-path); or return 1
    set -l list $source_dir/packages/node-tools.txt
    if not test -r $list
        echo "update: cannot read $list" >&2
        return 1
    end

    set -l specs (string match -rv '^\s*(#|$)' <$list)
    set -l failed 0
    for spec in $specs
        npm install -g --loglevel=error $spec; or set failed 1
    end
    return $failed
end
