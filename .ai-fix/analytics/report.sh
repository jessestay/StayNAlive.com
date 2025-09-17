#!/bin/bash

generate_pattern_report() {
    echo "AI Fix Pattern Analytics"
    echo "======================="
    echo
    
    # Success rate by pattern
    echo "Pattern Success Rates:"
    find .ai-fix/patterns -name "*.json" -exec jq -r '[.pattern, .success_rate] | @tsv' {} \; | \
        sort -k2 -nr | \
        column -t
    
    # Most common errors
    echo -e "\nMost Common Errors:"
    jq -r '.pattern' .ai-fix/patterns/*.json | \
        sort | \
        uniq -c | \
        sort -nr | \
        head -n10
    
    # Project type distribution
    echo -e "\nProject Type Distribution:"
    jq -r '.project_type' .ai-fix/patterns/*.json | \
        sort | \
        uniq -c | \
        sort -nr
} 