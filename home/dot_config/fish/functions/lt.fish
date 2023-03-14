function lt --wraps='exa $EXA_STANDARD_OPTIONS $EXA_LT_OPTIONS' --description 'alias lt exa $EXA_STANDARD_OPTIONS $EXA_LT_OPTIONS'
    if git rev-parse --is-inside-work-tree &>/dev/null
        exa $EXA_STANDARD_OPTIONS {$EXA_LT_OPTIONS} --git $argv
    else
        exa $EXA_STANDARD_OPTIONS {$EXA_LT_OPTIONS} $argv
    end
end
