function fromunixtime -d "Convert unix time (seconds or milliseconds) to a string."
    if string match -q --regex '\D' $argv[1]
        echo "Invalid timestamp format, '$argv[1]' is not an integer."
        return 1
    end

   set timestamp_length (string length $argv[1])

    if test $timestamp_length -eq 10
        # Handling seconds since epoch
        date -r $argv[1] +"%Y-%m-%dT%H:%M:%SZ"
    else if test $timestamp_length -eq 13
        set seconds (string sub -l 10 $argv[1])
        set milliseconds (string sub -s 11 $argv[1])
        # Combine date with milliseconds
        echo (date -r $seconds +"%Y-%m-%dT%H:%M:%S").$milliseconds"Z"
    else
        echo "Invalid timestamp format, should have length 10 (seconds) or 13 (milliseconds)"
        return 1
    end
end
