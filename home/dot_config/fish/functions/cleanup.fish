function cleanup
    command find $argv -name '*DS_Store' -or -name '*pyc' -or -name '*cache' -exec rm -rf {} \;
end
