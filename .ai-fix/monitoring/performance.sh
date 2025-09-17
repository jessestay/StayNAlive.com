#!/bin/bash

# Monitor build performance
monitor_performance() {
    local start_time=$SECONDS
    local start_memory=$(ps -o rss= -p $$)
    
    # Run the command
    "$@"
    local status=$?
    
    # Calculate metrics
    local duration=$((SECONDS - start_time))
    local memory_used=$(($(ps -o rss= -p $$) - start_memory))
    
    # Log performance data
    cat >> .ai-fix/monitoring/performance.log << EOF
{
    "timestamp": "$(date -u +"%Y-%m-%dT%H:%M:%SZ")",
    "command": "$1",
    "duration_seconds": $duration,
    "memory_kb": $memory_used,
    "exit_status": $status
}
EOF

    return $status
}

# Analyze performance data
analyze_performance() {
    jq -s '
        group_by(.command) |
        map({
            command: .[0].command,
            avg_duration: (map(.duration_seconds) | add / length),
            max_duration: (map(.duration_seconds) | max),
            avg_memory: (map(.memory_kb) | add / length),
            success_rate: (map(select(.exit_status == 0)) | length) / length
        })
    ' .ai-fix/monitoring/performance.log
} 