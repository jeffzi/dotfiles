# Environment variables
set -gx EDITOR (which code)

# Project paths for pj plugin
# https://github.com/oh-my-fish/plugin-pj
set -gx PROJECT_PATHS ~/Projects ~/Projects/personal ~/Projects/work/metamoki ~/Projects/work/metamoki/data-engineering/projects ~/Projects/work/metamoki/data-engineering/libs

# Homebrew
set -gx HOMEBREW_CASK_OPTS --no-quarantine

# Lua
set -gx LUA_INIT "local ok, ic = pcall(require, 'icecream'); if ok and type(ic.export) == 'function' then ic:export() end"
