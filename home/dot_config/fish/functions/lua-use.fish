function lua-use -d "Switch between Lua versions (luajit, lua5.4, lua5.1)"
    set -l lua_ver $argv[1]
    if test -z "$lua_ver"
        echo "Usage: lua-use <version>"
        echo "Available: luajit, lua5.4, lua5.1"
        echo "Current: "(command -v lua)
        return 1
    end
    set -l activate_script ~/.local/share/lua/$lua_ver/bin/activate.fish
    if test -f $activate_script
        source $activate_script
        echo "Switched to $lua_ver: "(lua -v)
    else
        echo "Unknown version: $lua_ver"
        echo "Available: luajit, lua5.4, lua5.1"
        return 1
    end
end
