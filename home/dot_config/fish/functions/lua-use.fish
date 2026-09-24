function lua-use -d "Switch between the Lua versions installed under ~/.local/share/lua"
    set -l lua_root ~/.local/share/lua
    set -l versions
    for activate_script in $lua_root/*/bin/activate.fish
        set -a versions (path basename (path dirname (path dirname $activate_script)))
    end

    if test (count $versions) -eq 0
        echo "No Lua versions installed under $lua_root" >&2
        return 1
    end

    set -l lua_ver $argv[1]
    if test -z "$lua_ver"
        echo "Usage: lua-use <version>" >&2
        echo "Available: "(string join ", " $versions) >&2
        echo "Current: "(command -v lua) >&2
        return 1
    end

    if not contains -- $lua_ver $versions
        echo "Unknown version: $lua_ver" >&2
        echo "Available: "(string join ", " $versions) >&2
        return 1
    end

    source $lua_root/$lua_ver/bin/activate.fish
    echo "Switched to $lua_ver: "(lua -v)
end
