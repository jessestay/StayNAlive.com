#!/bin/bash

# Colors for output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}Fixing PHP files...${NC}"

# Fix inline comments
find . -name "*.php" -type f -exec sed -i '' 's/\/\/ \([A-Za-z]\+.*[^.!?]\)$/\/\/ \1./' {} \;
find . -name "*.php" -type f -exec sed -i '' 's/\/\/ Silence is golden$/\/\/ Silence is golden./' {} \;

# Add blank line after file comment
find . -name "*.php" -type f -exec sed -i '' '/\*\//a\

/' {} \;

# Fix Yoda conditions
find . -name "*.php" -type f -exec sed -i '' 's/\([^!]\)\([=<>]\+\) *null/null \2 \1/g' {} \;
find . -name "*.php" -type f -exec sed -i '' 's/\([^!]\)\([=<>]\+\) *false/false \2 \1/g' {} \;
find . -name "*.php" -type f -exec sed -i '' 's/\([^!]\)\([=<>]\+\) *true/true \2 \1/g' {} \;

# Fix function spacing
find . -name "*.php" -type f -exec sed -i '' 's/(\([^[:space:]]\)/( \1/g' {} \;
find . -name "*.php" -type f -exec sed -i '' 's/\([^[:space:]]\))/\1 )/g' {} \;

echo -e "${GREEN}PHP files fixed!${NC}" 