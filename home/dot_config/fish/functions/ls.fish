function ls --wraps='exa' --description "Replace ls with exa"
    command eza -aF -w100 --group-directories-first --no-permissions --no-user --icons --no-time $argv
end
