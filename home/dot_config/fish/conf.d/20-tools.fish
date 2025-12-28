# Tool configurations

# eza (modern ls replacement)
set -gx EZA_CONFIG_DIR ~/.config/eza
# dim less important metadata
set -x EZA_COLORS "di=34:bd=33;2:cd=33;2:so=31;2:ex=37;2:ur=2;37:uw=2;37:ux=2;37:ue=2;37:gr=2;37:gw=2;37:gx=2;37:tr=2;37:tw=2;37:tx=2;37:xa=2;37:uu=2;37:lc=31;2:df=32;2:sn=37;2:sb=37;2:nb=37;2:nk=37;2:nm=37;2:ng=37;2:nt=37;2:da=2;34"

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
