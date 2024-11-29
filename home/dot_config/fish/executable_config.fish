# PATH
fish_add_path /opt/homebrew/bin
fish_add_path ~/.local/bin
fish_add_path ~/go

# default editor
set -gx EDITOR (which code)

# https://github.com/oh-my-fish/plugin-pj
set -gx PROJECT_PATHS ~/Projects ~/Projects/personal ~/Projects/work/metamoki ~/Projects/work/metamoki/data-engineering/projects ~/Projects/work/metamoki/data-engineering/libs
abbr -a pjo pj open

# pyenv init
set --erase PYENV_VERSION
status is-login; and pyenv init --path | source
status is-interactive; and pyenv init - | source

# exa
set -gx EZA_CONFIG_DIR ~/.config/eza
# dim less important metadata
set -x EXA_COLORS "di=34:bd=33;2:cd=33;2:so=31;2:ex=37;2:ur=2;37:uw=2;37:ux=2;37:ue=2;37:gr=2;37:gw=2;37:gx=2;37:tr=2;37:tw=2;37:tx=2;37:xa=2;37:uu=2;37:lc=31;2:df=32;2:sn=37;2:sb=37;2:nb=37;2:nk=37;2:nm=37;2:ng=37;2:nt=37;2:da=2;34"

# colororize man with bat
set -gx MANROFFOPT -c
set -gx MANPAGER "sh -c 'col -bx | bat -l man -p'"

# homebrew
set -gx HOMEBREW_CASK_OPTS --no-quarantine

# Lua
source ~/Projects/tools/lua/luajit/bin/activate.fish
set -gx LUA_INIT "local ok, ic = pcall(require, 'icecream'); if ok and type(ic.export) == 'function' then ic:export() end"

# starship prompt
starship init fish | source

# no greeting
set -g fish_greeting

# increase the maximum number of open file descriptors
# default is 256
ulimit -n 10240
