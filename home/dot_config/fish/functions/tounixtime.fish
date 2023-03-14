function tounixtime -d "Convert a string in UTC time to unix time."
    date $argv[1] +%s
end
