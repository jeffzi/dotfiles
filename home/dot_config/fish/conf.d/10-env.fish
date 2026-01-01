# Environment variables
set -gx EDITOR (which code)

# eza options
set -gx EZA_STANDARD_OPTIONS -la -F --icons --group-directories-first --time-style=long-iso --git -o
set -gx EZA_LL_OPTIONS -la -F --icons --group-directories-first --time-style=long-iso --git
set -gx EZA_LS_OPTIONS -la -F --icons --group-directories-first --time-style=long-iso --no-permissions --no-user
set -gx EZA_LT_OPTIONS --tree --no-permissions --no-user

# Project paths for pj plugin
# https://github.com/oh-my-fish/plugin-pj
set -gx PROJECT_PATHS ~/Projects ~/Projects/personal ~/Projects/work/metamoki ~/Projects/work/metamoki/data-engineering/projects ~/Projects/work/metamoki/data-engineering/libs

# Homebrew
set -gx HOMEBREW_CASK_OPTS --no-quarantine

# Lua
set -gx LUA_INIT "local ok, ic = pcall(require, 'icecream'); if ok and type(ic.export) == 'function' then ic:export() end"
