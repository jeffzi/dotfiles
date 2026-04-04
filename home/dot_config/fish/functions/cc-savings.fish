function cc-savings -d "Show combined token savings from Headroom proxy and RTK"
    set -l proxy_url http://localhost:8787

    # Proxy must be running
    if not curl -sf "$proxy_url/health" >/dev/null 2>&1
        echo "Error: Headroom proxy is not running" >&2
        return 1
    end

    # Headroom stats
    set -l raw (curl -sf "$proxy_url/stats" 2>/dev/null)
    if test $status -ne 0
        echo "Error: failed to fetch Headroom stats" >&2
        return 1
    end

    # Detect schema-only response (no session data yet)
    if echo "$raw" | grep -q 'int,' 2>/dev/null
        echo ""
        echo "Headroom Proxy"
        echo "──────────────"
        echo "  No session data yet (start a Claude Code session first)"
    else
        set -l lifetime_usd (echo "$raw" | jq -r '.persistent_savings.lifetime.compression_savings_usd // 0 | . * 10 | round | . / 10')
        set -l lifetime_tokens (echo "$raw" | jq -r '.persistent_savings.lifetime.tokens_saved // 0')

        echo ""
        echo "Headroom Proxy (lifetime)"
        echo "─────────────────────────"
        printf "  Tokens saved:   %s\n" "$lifetime_tokens"
        printf "  USD saved:      \$%s\n" "$lifetime_usd"
    end

    # RTK stats (optional)
    if command -q rtk
        set -l rtk_json (rtk gain -f json 2>/dev/null)
        if test $status -eq 0 -a -n "$rtk_json"
            set -l rtk_saved (echo "$rtk_json" | jq -r '.summary.total_saved // 0')
            set -l rtk_total (echo "$rtk_json" | jq -r '(.summary.total_input // 0) + (.summary.total_saved // 0)')
            set -l avg_pct (echo "$rtk_json" | jq -r '.summary.avg_savings_pct // 0 | . * 10 | round | . / 10')
            set -l cmds (echo "$rtk_json" | jq -r '.summary.total_commands // 0')
            echo ""
            echo "RTK CLI Filtering"
            echo "─────────────────"
            printf "  Tokens saved:   %s / %s  (%s%%)\n" "$rtk_saved" "$rtk_total" "$avg_pct"
            printf "  Commands:       %s\n" "$cmds"
        end
    end

    echo ""
end
