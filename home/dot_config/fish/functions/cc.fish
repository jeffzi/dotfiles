function cc -d "Launch Claude Code through Headroom proxy for token compression"
    # Start Headroom proxy if not already running
    if not curl -sf http://localhost:8787/health >/dev/null 2>&1
        # Rotate log if > 5MB
        set -l log_file ~/.headroom/proxy.log
        if test -f $log_file; and test (stat -f%z $log_file) -gt 5242880
            mv $log_file $log_file.1
        end

        echo "Upgrading Headroom..."
        uv tool upgrade headroom-ai

        echo "Starting Headroom proxy..."
        headroom proxy --no-telemetry --log-file $log_file >/dev/null 2>&1 &
        disown

        # Wait for proxy to become healthy
        set -l retries 0
        while not curl -sf http://localhost:8787/health >/dev/null 2>&1
            set retries (math $retries + 1)
            if test $retries -gt 30
                echo "Error: Headroom proxy failed to start after 30s"
                return 1
            end
            sleep 1
        end
        echo "Headroom proxy ready."
    end

    ANTHROPIC_BASE_URL=http://localhost:8787 claude --dangerously-skip-permissions $argv
end
