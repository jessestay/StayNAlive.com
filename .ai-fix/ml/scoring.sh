#!/bin/bash

# Score pattern matches
score_pattern() {
    local pattern="$1"
    local error_msg="$2"
    
    # Calculate similarity score
    local similarity=$(string_similarity "$pattern" "$error_msg")
    
    # Get pattern success rate
    local success_rate=$(jq '.success_rate' "$pattern_file")
    
    # Calculate final score
    echo "scale=2; ($similarity * 0.7) + ($success_rate * 0.3)" | bc
}

# String similarity using Levenshtein distance
string_similarity() {
    local str1="$1"
    local str2="$2"
    python3 -c "
import Levenshtein
print(1 - Levenshtein.distance('$str1', '$str2') / max(len('$str1'), len('$str2')))
"
} 