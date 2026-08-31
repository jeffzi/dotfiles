function cc -d "Launch Claude Code"
    claude --dangerously-skip-permissions --model 'claude-opus-4-6[1m]' --effort medium $argv
end
