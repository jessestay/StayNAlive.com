#!/bin/bash

PATTERN_REPO_URL="https://github.com/jessestay/ai-fix-patterns"

# Sync patterns with central repository
sync_patterns() {
    # Check if we have access token
    if [ -z "$PATTERN_REPO_TOKEN" ]; then
        echo -e "${YELLOW}No access token found for pattern repository${NC}"
        return 1
    fi
    
    # Create patterns directory if it doesn't exist
    mkdir -p .ai-fix/patterns
    
    # Upload new patterns
    find .ai-fix/patterns -name "*.json" -mtime -1 | while read -r pattern_file; do
        # Only sync successful patterns
        if jq -e '.success_rate > 0.8' "$pattern_file" > /dev/null; then
            curl -X POST \
                -H "Authorization: token $PATTERN_REPO_TOKEN" \
                -H "Content-Type: application/json" \
                -d @"$pattern_file" \
                "$PATTERN_REPO_URL/contents/patterns/$(basename "$pattern_file")"
        fi
    done
    
    # Download new patterns
    curl -s \
        -H "Authorization: token $PATTERN_REPO_TOKEN" \
        "$PATTERN_REPO_URL/contents/patterns" | \
    jq -r '.[] | .download_url' | while read -r url; do
        curl -s "$url" > ".ai-fix/patterns/$(basename "$url")"
    done
}

# Apply patterns to fix errors
apply_patterns() {
    local error_msg="$1"
    local file="$2"
    
    for pattern in .ai-fix/patterns/*.json; do
        if jq -e --arg msg "$error_msg" '.pattern | test($msg)' "$pattern" > /dev/null; then
            local fix=$(jq -r '.fix' "$pattern")
            eval "FILE=\"$file\" $fix"
            return 0
        fi
    done
    return 1
} 