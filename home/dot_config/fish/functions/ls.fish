function ls --wraps='eza' --description "Replace ls with eza"
    command eza -aF -w100 --group-directories-first --no-permissions --no-user --icons --no-time $argv
end
