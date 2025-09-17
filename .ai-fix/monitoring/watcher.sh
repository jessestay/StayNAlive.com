#!/bin/bash

# Monitor for errors in real-time
watch_for_errors() {
    local log_file="$1"
    local error_patterns=(
        "error" "Error" "ERROR"
        "warning" "Warning" "WARNING"
        "fail" "Fail" "FAIL"
        "exception" "Exception" "EXCEPTION"
        "deprecated" "Deprecated" "DEPRECATED"
    )
    
    # Use inotify/fswatch to monitor file changes
    if command -v fswatch >/dev/null 2>&1; then
        fswatch -0 "$log_file" | while read -d "" event; do
            check_for_errors "$log_file" "${error_patterns[@]}"
        done
    else
        # Fallback to polling
        while true; do
            check_for_errors "$log_file" "${error_patterns[@]}"
            sleep 1
        done
    fi
}

# Check file for errors
check_for_errors() {
    local log_file="$1"
    shift
    local patterns=("$@")
    
    for pattern in "${patterns[@]}"; do
        if tail -n 50 "$log_file" | grep -q "$pattern"; then
            local error_msg=$(tail -n 50 "$log_file" | grep -B 2 -A 2 "$pattern")
            fix_with_ai "$error_msg" "$log_file"
        fi
    done
} 