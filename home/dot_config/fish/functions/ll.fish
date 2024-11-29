function ll --wraps='exa $EXA_STANDARD_OPTIONS' --description "Use exa and its git options if in a git repo"
    command eza -laF --icons --group-directories-first --time-style=long-iso --git $argv
end
