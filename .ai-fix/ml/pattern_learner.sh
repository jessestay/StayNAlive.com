#!/bin/bash

# Pattern learning system
learn_pattern() {
    local error_msg="$1"
    local fix_command="$2"
    local success="$3"
    
    # Create pattern hash
    local pattern_hash=$(echo "$error_msg" | sha256sum | cut -d' ' -f1)
    
    # Store pattern data
    cat >> ".ai-fix/patterns/${pattern_hash}.json" << EOL
{
    "pattern": "$(echo "$error_msg" | jq -R -s '.')",
    "fix": "$(echo "$fix_command" | jq -R -s '.')",
    "success_rate": $success,
    "last_used": "$(date -u +"%Y-%m-%dT%H:%M:%SZ")",
    "project_type": "$PROJECT_TYPE",
    "context": {
        "os": "$(uname -s)",
        "dependencies": $(jq -c '.dependencies // {}' package.json 2>/dev/null || echo '{}')
    }
}
EOL
}

# Pattern matching using ML
match_pattern() {
    local error_msg="$1"
    
    # Use fuzzy matching to find similar patterns
    local matches=$(find .ai-fix/patterns -name "*.json" -exec sh -c '
        jq -r '"'"'.pattern'"'"' "{}" | similarity-score "'"$error_msg"'" 
    ' \;)
    
    # Return best match above threshold
    echo "$matches" | sort -nr | head -n1
} 