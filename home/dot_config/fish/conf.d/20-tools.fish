# Tool configurations

# Colorize man pages with bat
set -gx MANROFFOPT -c
set -gx MANPAGER "sh -c 'col -bx | bat -l man -p'"

# Lua activation (sourced after PATH is set)
if test -f ~/.local/share/lua/luajit/bin/activate.fish
    source ~/.local/share/lua/luajit/bin/activate.fish
end

# Fish configuration
set -g fish_greeting  # no greeting

# System limits
ulimit -n 10240  # increase max open file descriptors (default: 256)
