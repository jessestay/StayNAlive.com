#!/bin/bash

# Colors for output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
RED='\033[0;31m'
NC='\033[0m'

# Check for required software
command -v node >/dev/null 2>&1 || {
    echo -e "${RED}Error: Node.js is required but not installed.${NC}"
    echo "Install Node.js from https://nodejs.org/"
    exit 1
}

command -v composer >/dev/null 2>&1 || {
    echo -e "${RED}Error: Composer is required but not installed.${NC}"
    echo "Install Composer from https://getcomposer.org/"
    exit 1
}

command -v docker >/dev/null 2>&1 || {
    echo -e "${RED}Error: Docker is required but not installed.${NC}"
    echo "Install Docker from https://www.docker.com/"
    exit 1
}

# Install dependencies
echo -e "${BLUE}Installing Node dependencies...${NC}"
npm install --legacy-peer-deps

echo -e "${BLUE}Installing Composer dependencies...${NC}"
composer install

# Setup WordPress development environment
echo -e "${BLUE}Setting up WordPress development environment...${NC}"
npm run dev

# Create necessary directories
mkdir -p {build,dist}

# Setup git hooks
if [ -d ".git" ]; then
    echo -e "${BLUE}Setting up git hooks...${NC}"
    cp scripts/pre-commit.sh .git/hooks/pre-commit
    chmod +x .git/hooks/pre-commit
fi

echo -e "${GREEN}Development environment setup complete!${NC}"
echo -e "Run ${BLUE}npm run watch${NC} to start development" 