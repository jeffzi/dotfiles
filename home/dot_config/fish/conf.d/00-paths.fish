# PATH setup - loaded first to ensure tools are available
fish_add_path /opt/homebrew/bin
fish_add_path ~/.local/bin
fish_add_path ~/.cargo/bin
fish_add_path ~/go

# uv-managed Python 3.8 for legacy poetry projects
if command -q uv
    set -l py38_path (uv python find 3.8 2>/dev/null | xargs dirname)
    if test -n "$py38_path"
        fish_add_path --path $py38_path
    end
end
