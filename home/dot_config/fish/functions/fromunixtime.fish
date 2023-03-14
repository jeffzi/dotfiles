function fromunixtime -d "Convert unix time (seconds or milliseconds) to a string."
    if string match -q --regex '\D' $argv[1]
        echo "Invalid timestamp format, '$argv[1]' is not an integer."
        return 1
    end

    if test (string length $argv[1]) -eq 10
        date -ud @$argv[1] '+%F %T'
    else if test (string length $argv[1]) -eq 13
        date -ud @(math $argv[1] / 1000.0) '+%F %T.%3N'
    else
        echo "Invalid timestamp format, should have length 10 (seconds) or 13 (milliseconds)"
        return 1
    end
end
