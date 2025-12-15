# Add uv-managed Python 3.8 to PATH for legacy poetry projects
if command -q uv
    set -l py38_path (uv python find 3.8 2>/dev/null | xargs dirname)
    if test -n "$py38_path"
        fish_add_path --path $py38_path
    end
end
