function lt --wraps='exa' --description "Replace tree with eza"
    set base_args -laTF --icons --group-directories-first --total-size --no-time --no-permissions --no-user
    set has_L_arg (string match -r -- '-L[0-9]*' $argv)

    if test -z "$has_L_arg"
        # If no -L argument, add -L1 to the command
        command eza $base_args -L1 $argv
    else
        command eza $base_args $argv
    end
end
