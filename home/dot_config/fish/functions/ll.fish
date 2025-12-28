function ll --wraps='eza $EZA_STANDARD_OPTIONS' --description "Use eza and its git options if in a git repo"
    command eza -laF --icons --group-directories-first --time-style=long-iso --git $argv
end
