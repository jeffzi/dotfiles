function jqs -d "Use jq to filter a jsonl file" --argument-names "filters filename"
    command jq --slurp ".[] | $argv[1]" $argv[2]
end
