#!/bin/bash

# Colors for output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}Running automated fixes...${NC}"

# Fix PHP files
echo "Fixing PHP files..."
find . -name "*.php" -type f -exec php -l {} \;
./vendor/bin/phpcbf

# Fix PHP array syntax
echo "Fixing PHP array syntax..."
find . -name "*.php" -type f -exec sed -i '' 's/array(/[/g' {} \;
find . -name "*.php" -type f -exec sed -i '' 's/)/]/g' {} \;

# Fix PHP string concatenation
echo "Fixing PHP string concatenation..."
find . -name "*.php" -type f -exec sed -i '' 's/\. \"/\"/g' {} \;
find . -name "*.php" -type f -exec sed -i '' 's/\" \./\"/g' {} \;

# Fix PHP variable naming
echo "Fixing PHP variable naming..."
find . -name "*.php" -type f -exec sed -i '' 's/\$[A-Z]/\L&/g' {} \;

# Fix JavaScript async/await
echo "Fixing JavaScript async/await..."
find . -name "*.js" -type f -exec sed -i '' 's/new Promise/async function/g' {} \;
find . -name "*.js" -type f -exec sed -i '' 's/\.then/await/g' {} \;

# Fix CSS vendor prefixes
echo "Fixing CSS vendor prefixes..."
find . -name "*.css" -type f -exec sed -i '' 's/-webkit-//' {} \;
find . -name "*.css" -type f -exec sed -i '' 's/-moz-//' {} \;
find . -name "*.css" -type f -exec sed -i '' 's/-ms-//' {} \;

# Fix JavaScript files
echo "Fixing JavaScript files..."
npm run lint:js -- --fix

# Fix CSS files
echo "Fixing CSS files..."
npm run lint:css -- --fix

# Fix documentation
echo "Fixing documentation..."
find . -name "*.php" -type f -exec sed -i '' 's/@package staynalive/@package StayNAlive/' {} \;
find . -name "*.php" -type f -exec sed -i '' 's/\/\/ \([A-Za-z]\+.*[^.]\)$/\/\/ \1./' {} \;

# Fix Yoda conditions
echo "Fixing Yoda conditions..."
find . -name "*.php" -type f -exec sed -i '' 's/if (\$\([a-zA-Z_]*\) [=!]== \(.*\))/if (\2 [=!]== \$\1)/' {} \;

echo -e "${GREEN}Fixes complete!${NC}" 