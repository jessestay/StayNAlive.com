#!/bin/bash

# Colors for output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
RED='\033[0;31m'
NC='\033[0m'

# Check for PHP
if ! command -v php >/dev/null 2>&1; then
    echo -e "${RED}Error: PHP is required but not installed.${NC}"
    if [[ "$OSTYPE" == "darwin"* ]]; then
        echo "Install PHP using: brew install php"
    else
        echo "Please install PHP using your system's package manager"
    fi
    exit 1
fi

echo -e "${BLUE}Installing Stay N Alive Theme...${NC}"

# Check for composer and offer to install if missing
if ! command -v composer >/dev/null 2>&1; then
    echo -e "${BLUE}Composer not found. Would you like to install it? (y/n)${NC}"
    read -r install_composer
    if [[ "$install_composer" =~ ^[Yy]$ ]]; then
        echo -e "${BLUE}Downloading Composer installer...${NC}"
        php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');"
        EXPECTED_CHECKSUM="$(php -r 'copy("https://composer.github.io/installer.sig", "php://stdout");')"
        ACTUAL_CHECKSUM="$(php -r "echo hash_file('sha384', 'composer-setup.php');")"

        if [ "$EXPECTED_CHECKSUM" != "$ACTUAL_CHECKSUM" ]; then
            echo -e "${RED}Composer installer is corrupt${NC}"
            rm composer-setup.php
            exit 1
        fi

        echo -e "${BLUE}Installing Composer...${NC}"
        php composer-setup.php
        if [ ! -f "composer.phar" ]; then
            echo -e "${RED}Failed to create composer.phar${NC}"
            exit 1
        fi

        php -r "unlink('composer-setup.php');"
        if ! sudo mv composer.phar /usr/local/bin/composer; then
            echo -e "${RED}Failed to move composer to /usr/local/bin/${NC}"
            echo -e "Trying alternative installation..."
            sudo mkdir -p /usr/local/bin
            sudo mv composer.phar /usr/local/bin/composer
        fi

        if [ $? -ne 0 ]; then
            echo -e "${RED}Failed to install Composer. Please install manually:${NC}"
            echo "https://getcomposer.org/download/"
            exit 1
        fi

        # Verify installation
        if ! command -v composer >/dev/null 2>&1; then
            echo -e "${RED}Composer installation failed. Please install manually:${NC}"
            echo "https://getcomposer.org/download/"
            exit 1
        fi

        echo -e "${GREEN}Composer installed successfully!${NC}"
    else
        echo -e "${RED}Composer is required. Please install it manually:${NC}"
        echo "https://getcomposer.org/download/"
        exit 1
    fi
fi

# Create index.php if it doesn't exist
if [ ! -f "index.php" ]; then
    echo "<?php // Silence is golden" > index.php
fi

# Install dependencies
echo -e "${BLUE}Installing Node dependencies...${NC}"
if ! npm install --legacy-peer-deps; then
    echo -e "${RED}Failed to install Node dependencies. Please check your npm installation.${NC}"
    exit 1
fi

# Fix npm audit issues but don't fail if they can't be fixed
echo -e "${BLUE}Attempting to fix npm audit issues...${NC}"
npm audit fix || true

echo -e "${BLUE}Installing Composer dependencies...${NC}"
if ! composer install; then
    echo -e "${RED}Failed to install Composer dependencies.${NC}"
    exit 1
fi

# Build assets
echo -e "${BLUE}Building assets...${NC}"
if ! npm run build; then
    echo -e "${RED}Failed to build assets.${NC}"
    exit 1
fi

# Create production build
echo -e "${BLUE}Creating production build...${NC}"
mkdir -p dist/staynalive

# Copy theme files
if ! cp -r {assets,inc,languages,parts,patterns,styles,templates,tests} dist/staynalive/ 2>/dev/null; then
    echo -e "${RED}Failed to copy theme directories. Please ensure all required directories exist.${NC}"
    exit 1
fi

if ! cp {style.css,functions.php,theme.json,index.php} dist/staynalive/ 2>/dev/null; then
    echo -e "${RED}Failed to copy theme files. Please ensure all required files exist.${NC}"
    exit 1
fi

# Create zip file
cd dist
zip -r staynalive.zip staynalive -x ".*" -x "__MACOSX"
cd ..

echo -e "${GREEN}Installation complete!${NC}"
echo -e "Theme zip created at: ${BLUE}dist/staynalive.zip${NC}"
echo -e "You can now install this theme in WordPress through:"
echo -e "1. WordPress Admin > Appearance > Themes > Add New > Upload Theme"
echo -e "2. Or copy the contents of ${BLUE}dist/staynalive${NC} to your wp-content/themes directory"

mkdir -p src
touch src/index.js 