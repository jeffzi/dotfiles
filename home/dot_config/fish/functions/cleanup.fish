function cleanup -d "Delete .DS_Store, Python bytecode, and tool caches under the given directories"
    if test (count $argv) -eq 0
        echo "Usage: cleanup <dir>..." >&2
        return 1
    end

    # -prune keeps find from descending into a directory it is about to delete.
    command find $argv \( \
        -name .DS_Store -o -name '*.pyc' -o -name __pycache__ \
        -o -name .pytest_cache -o -name .ruff_cache -o -name .mypy_cache \
        \) -prune -exec rm -rf {} +
end
