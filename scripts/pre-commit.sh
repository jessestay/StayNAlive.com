#!/bin/bash

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m'

echo "Running pre-commit checks..."

# Run linters
echo "Running linters..."
npm run lint

if [ $? -ne 0 ]; then
    echo -e "${RED}Linting failed. Please fix the errors and try again.${NC}"
    exit 1
fi

# Run tests
echo "Running tests..."
npm run test

if [ $? -ne 0 ]; then
    echo -e "${RED}Tests failed. Please fix the errors and try again.${NC}"
    exit 1
fi

echo -e "${GREEN}All checks passed!${NC}"
exit 0 