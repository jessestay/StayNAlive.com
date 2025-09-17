#!/bin/bash

# Pattern database manager
PATTERN_DB_VERSION="1.0.0"
PATTERN_DB_PATH=".ai-fix/patterns/db.json"

# Initialize pattern database
init_pattern_db() {
    if [ ! -f "$PATTERN_DB_PATH" ]; then
        echo '{
            "version": "'"$PATTERN_DB_VERSION"'",
            "patterns": {},
            "metadata": {
                "created": "'$(date -u +"%Y-%m-%dT%H:%M:%SZ")'",
                "last_updated": "'$(date -u +"%Y-%m-%dT%H:%M:%SZ")'",
                "total_patterns": 0,
                "success_rate": 0
            }
        }' > "$PATTERN_DB_PATH"
    fi
}

# Add pattern to database
add_pattern() {
    local error_pattern="$1"
    local fix_command="$2"
    local success="$3"
    local context="$4"
    
    # Create pattern hash
    local pattern_hash=$(echo "$error_pattern" | sha256sum | cut -d' ' -f1)
    
    # Update pattern database
    jq --arg hash "$pattern_hash" \
       --arg pattern "$error_pattern" \
       --arg fix "$fix_command" \
       --arg success "$success" \
       --arg context "$context" \
       --arg date "$(date -u +"%Y-%m-%dT%H:%M:%SZ")" \
       '.patterns[$hash] = {
           "pattern": $pattern,
           "fix": $fix,
           "success_rate": ($success | tonumber),
           "uses": ((.patterns[$hash].uses // 0) + 1),
           "last_used": $date,
           "context": ($context | fromjson),
           "history": ((.patterns[$hash].history // []) + [{
               "date": $date,
               "success": ($success | tonumber)
           }])
       } | .metadata.last_updated = $date | .metadata.total_patterns = (.patterns | length)' \
       "$PATTERN_DB_PATH" > "${PATTERN_DB_PATH}.tmp" && mv "${PATTERN_DB_PATH}.tmp" "$PATTERN_DB_PATH"
}

# Find similar patterns
find_similar_patterns() {
    local error_msg="$1"
    local threshold="${2:-0.7}"  # Default similarity threshold
    
    jq -r --arg msg "$error_msg" --arg threshold "$threshold" '
        .patterns | to_entries[] | select(
            (.value.pattern | similarity($msg)) >= ($threshold | tonumber)
        ) | [.value.pattern, .value.success_rate, .value.fix] | @tsv
    ' "$PATTERN_DB_PATH"
}

# Analyze pattern effectiveness
analyze_patterns() {
    jq -r '
        .patterns | to_entries[] | 
        .value | 
        [
            .pattern,
            .success_rate,
            .uses,
            (.history | length),
            (.history | map(.success) | add / length)
        ] | @tsv
    ' "$PATTERN_DB_PATH" | 
    column -t -s $'\t' -N "Pattern,Success Rate,Uses,History Size,Avg Success"
}

# Clean up old patterns
cleanup_patterns() {
    local days="${1:-30}"  # Default to 30 days
    local threshold="${2:-0.3}"  # Default success threshold
    
    jq --arg days "$days" --arg threshold "$threshold" '
        .patterns |= with_entries(
            select(
                .value.last_used >= (now - ($days | tonumber * 86400)) or
                .value.success_rate >= ($threshold | tonumber)
            )
        )
    ' "$PATTERN_DB_PATH" > "${PATTERN_DB_PATH}.tmp" && mv "${PATTERN_DB_PATH}.tmp" "$PATTERN_DB_PATH"
} 