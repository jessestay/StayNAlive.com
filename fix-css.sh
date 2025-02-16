#!/bin/bash

# Colors for output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}Fixing CSS files...${NC}"

# Convert spaces to tabs
find assets/css -name "*.css" -type f -exec sed -i '' 's/^    /\t/g' {} \;

# Add newlines at end of files
find assets/css -name "*.css" -type f -exec sed -i '' -e '$a\' {} \;

# Fix color formats (#ffffff -> #fff, etc)
find assets/css -name "*.css" -type f -exec sed -i '' \
    -e 's/#ffffff/#fff/g' \
    -e 's/#000000/#000/g' \
    -e 's/#333333/#333/g' {} \;

# Fix string quotes (single -> double)
find assets/css -name "*.css" -type f -exec sed -i '' "s/'([^']*)'/"'"\\1"'"'/g" {} \;

# Fix comma spacing in rgba/hsla
find assets/css -name "*.css" -type f -exec sed -i '' 's/rgba([0-9]\+,[0-9]\+,[0-9]\+,[0-9\.]\+)/rgba(\1, \2, \3, \4)/g' {} \;

# Add empty lines before rules
find assets/css -name "*.css" -type f -exec sed -i '' 's/}\([^}]*{[^}]*}\)/}\n\n\1/g' {} \;

echo -e "${GREEN}CSS files fixed!${NC}" 