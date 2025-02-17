#!/usr/bin/env bash

# Colors for output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m'

# Source AI fix scripts
for script in .ai-fix/{ml,sync}/*.sh; do
    if [ -f "$script" ]; then
        source "$script"
    fi
done

# Initialize AI fix
if [ ! -d ".ai-fix" ]; then
    mkdir -p .ai-fix/{ml,sync,patterns}
    cp -r .ai-fix/templates/* .ai-fix/
fi

echo -e "${BLUE}Installing Stay N Alive Theme...${NC}"

# Check write permissions
if [ ! -w "." ]; then
    echo -e "${RED}Error: Current directory is not writable${NC}"
    exit 1
fi

# Check for required commands
for cmd in php composer node npm zip; do
    if ! command -v $cmd &> /dev/null; then
        echo -e "${RED}Error: $cmd is required but not installed.${NC}"
        exit 1
    fi
done

# Check PHP version
PHP_VERSION=$(php -r 'echo PHP_VERSION;')
if [[ $(printf '%s\n' "7.4" "$PHP_VERSION" | sort -V | head -n1) != "7.4" ]]; then
    echo -e "${RED}Error: PHP 7.4 or higher is required.${NC}"
    exit 1
fi

# Create necessary directories
if ! mkdir -p {assets/{css/{base,blocks,components,utilities},js},inc/classes,languages,parts,patterns,styles,templates,tests,src}; then
    echo -e "${RED}Error: Failed to create directory structure${NC}"
    exit 1
fi

# Create .gitkeep files in empty directories
find . -type d -empty -exec touch {}/.gitkeep \;

# Create required files if they don't exist
if [ ! -f "style.css" ]; then
    echo "Creating style.css..."
    cat > style.css << 'EOL'
/*
Theme Name: Stay N Alive
Theme URI: https://staynalive.com
Author: Jesse Stay
Author URI: https://staynalive.com
Description: A modern block-based theme for Stay N Alive
Version: 1.0.0
Requires at least: 6.0
Tested up to: 6.4
Requires PHP: 7.4
License: GNU General Public License v2 or later
License URI: LICENSE
Text Domain: staynalive
*/
EOL
fi

if [ ! -f "functions.php" ]; then
    echo "Creating functions.php..."
    cat > functions.php << 'EOL'
<?php
/**
 * Theme functions and definitions
 *
 * @package StayNAlive
 */

if ( ! defined( 'STAYNALIVE_VERSION' ) ) {
    define( 'STAYNALIVE_VERSION', '1.0.0' );
}

function staynalive_setup() {
    add_theme_support( 'wp-block-styles' );
    add_theme_support( 'editor-styles' );
    add_theme_support( 'responsive-embeds' );
}
add_action( 'after_setup_theme', 'staynalive_setup' );
EOL
fi

if [ ! -f "theme.json" ]; then
    echo "Creating theme.json..."
    cat > theme.json << 'EOL'
{
    "$schema": "https://schemas.wp.org/trunk/theme.json",
    "version": 2,
    "settings": {
        "color": {
            "palette": [
                {
                    "slug": "primary",
                    "color": "#1e73be",
                    "name": "Primary"
                }
            ]
        },
        "typography": {
            "fontFamilies": [
                {
                    "fontFamily": "Open Sans, sans-serif",
                    "slug": "primary",
                    "name": "Primary"
                }
            ]
        }
    }
}
EOL
fi

# After creating theme.json
if [ ! -f "index.php" ]; then
    echo "Creating index.php..."
    cat > index.php << 'EOL'
<?php
/**
 * Silence is golden.
 *
 * @package StayNAlive
 */
EOL
fi

# Create required template files
if [ ! -f "templates/index.html" ]; then
    echo "Creating index template..."
    cat > templates/index.html << 'EOL'
<!-- wp:template-part {"slug":"header","tagName":"header"} /-->
<!-- wp:group {"tagName":"main"} -->
<main class="wp-block-group">
    <!-- wp:post-content /-->
</main>
<!-- /wp:group -->
<!-- wp:template-part {"slug":"footer","tagName":"footer"} /-->
EOL
fi

if [ ! -f "parts/header.html" ]; then
    echo "Creating header part..."
    cat > parts/header.html << 'EOL'
<!-- wp:group {"tagName":"header","className":"site-header"} -->
<header class="wp-block-group site-header">
    <!-- wp:site-title /-->
    <!-- wp:navigation /-->
</header>
<!-- /wp:group -->
EOL
fi

if [ ! -f "parts/footer.html" ]; then
    echo "Creating footer part..."
    cat > parts/footer.html << 'EOL'
<!-- wp:group {"tagName":"footer","className":"site-footer"} -->
<footer class="wp-block-group site-footer">
    <!-- wp:paragraph {"align":"center"} -->
    <p class="has-text-align-center">© 2024 Stay N Alive</p>
    <!-- /wp:paragraph -->
</footer>
<!-- /wp:group -->
EOL
fi

# After creating directories
if [ ! -f "assets/css/base/base.css" ]; then
    echo "Creating base CSS..."
    cat > assets/css/base/base.css << 'EOL'
:root {
    --color-primary: #1e73be;
    --color-text: #333333;
    --color-background: #ffffff;
}

body {
    margin: 0;
    font-family: var(--wp--preset--font-family--primary);
    color: var(--color-text);
    background: var(--color-background);
}
EOL
fi

# Cleanup function
cleanup() {
    if [ -d "dist" ]; then
        rm -rf dist
    fi
    if [ -d "node_modules" ]; then
        rm -rf node_modules
    fi
    if [ -d "vendor" ]; then
        rm -rf vendor
    fi
    if [ -d "build" ]; then
        rm -rf build
    fi
}

# Trap errors
trap 'echo -e "${RED}Installation failed${NC}"; cleanup; exit 1' ERR INT TERM

# Install dependencies
echo -e "${BLUE}Installing Node dependencies...${NC}"
# Remove package-lock.json and node_modules to ensure clean install
rm -f package-lock.json
rm -rf node_modules

# Install with legacy peer deps to handle WordPress package conflicts
if ! npm install --legacy-peer-deps --no-audit; then
    echo -e "${RED}Failed to install Node dependencies.${NC}"
    echo -e "Try running: npm install --legacy-peer-deps --verbose"
    exit 1
fi

echo -e "${BLUE}Installing Composer dependencies...${NC}"
# Remove composer.lock if it exists to force fresh install
if [ -f "composer.lock" ]; then
    rm composer.lock
fi

# Remove vendor directory to ensure clean install
if [ -d "vendor" ]; then
    rm -rf vendor
fi

# Install PHP Compatibility first
if ! composer require --dev phpcompatibility/php-compatibility:^9.3; then
    echo -e "${RED}Failed to install PHP Compatibility.${NC}"
    exit 1
fi

# Install other dev dependencies
if ! composer require --dev dealerdirect/phpcodesniffer-composer-installer:^1.0 wp-coding-standards/wpcs:^3.0 squizlabs/php_codesniffer:^3.7.2; then
    echo -e "${RED}Failed to install dev dependencies.${NC}"
    exit 1
fi

# After installing dependencies but before running linters
echo -e "${BLUE}Fixing PHP coding standards...${NC}"
# Run PHPCBF to automatically fix violations that can be fixed
if command -v ./vendor/bin/phpcbf >/dev/null 2>&1; then
    echo -e "${BLUE}Running PHPCBF to fix violations...${NC}"
    # First run: Fix all automatically fixable violations
    ./vendor/bin/phpcbf --standard=WordPress inc/*.php *.php
    
    # Second run: Fix specific remaining issues
    for file in inc/*.php *.php; do
        # Fix function comment style
        if ./vendor/bin/phpcs "$file" | grep -q "You must use \"/**\" style comments for a function comment"; then
            sed -i '' '/^[[:space:]]*\/\// {N; s/\/\/ \(.*\)\n/\/\*\*\n * \1\n *\/\n/}' "$file"
        fi
        
        # Fix trailing whitespace
        if ./vendor/bin/phpcs "$file" | grep -q "Whitespace found at end of line"; then
            sed -i '' 's/[[:space:]]*$//' "$file"
        fi
        
        # Fix missing comma in arrays
        if ./vendor/bin/phpcs "$file" | grep -q "There should be a comma after the last array item"; then
            sed -i '' '/^[[:space:]]*[^,[:space:]]\+[[:space:]]*$/s/$/,/' "$file"
        fi
        
        # Fix file comment spacing
        if ./vendor/bin/phpcs "$file" | grep -q "must be exactly one blank line after the file comment"; then
            sed -i '' '/^\\*\\//a\\' "$file"
        fi
        
        # Fix inline comment periods
        if ./vendor/bin/phpcs "$file" | grep -q "Inline comments must end in full-stops"; then
            sed -i '' 's/\/\/ \([A-Za-z].*[^.!?]\)$/\/\/ \1./' "$file"
        fi
        
        # Fix Yoda conditions
        if ./vendor/bin/phpcs "$file" | grep -q "Use Yoda Condition checks"; then
            sed -i '' 's/\([^!]\)\([=<>]\+\) *null/null \2 \1/g' "$file"
            sed -i '' 's/\([^!]\)\([=<>]\+\) *false/false \2 \1/g' "$file"
            sed -i '' 's/\([^!]\)\([=<>]\+\) *true/true \2 \1/g' "$file"
        fi
    done
    
    # Third run: Verify fixes
    ./vendor/bin/phpcbf --standard=WordPress inc/*.php *.php
else
    echo -e "${RED}PHPCBF not found. Please ensure composer dependencies are installed.${NC}"
    exit 1
fi

# Run linting
echo -e "${BLUE}Running linters...${NC}"
npm run lint || true

# Create webpack entry point
if [ ! -f "src/index.js" ]; then
    echo "Creating webpack entry point..."
    cat > src/index.js << 'EOL'
// Import styles
import '../assets/css/base/base.css';

// Initialize theme
console.log('Stay N Alive theme initialized');
EOL
fi

# Validate required files before build
echo -e "${BLUE}Validating required files...${NC}"
required_files=("style.css" "functions.php" "theme.json" "templates/index.html" "parts/header.html" "parts/footer.html" "src/index.js" "assets/css/base/base.css")
for file in "${required_files[@]}"; do
    dir=$(dirname "$file")
    if [ ! -d "$dir" ]; then
        echo -e "${RED}Error: Directory $dir does not exist${NC}"
        exit 1
    fi
    if [ ! -f "$file" ]; then
        echo -e "${RED}Error: Required file $file is missing${NC}"
        exit 1
    fi
done

# Ensure build directory exists
mkdir -p build/css

# Build assets
echo -e "${BLUE}Building assets...${NC}"
# Capture build output and errors
BUILD_OUTPUT=$(npm run build 2>&1)
BUILD_STATUS=$?

if [ $BUILD_STATUS -ne 0 ]; then
    # Extract error message
    ERROR_MSG=$(echo "$BUILD_OUTPUT" | grep -A 2 "Error:" | head -n3)
    
    # Try to fix with AI
    if type fix_with_ai >/dev/null 2>&1; then
        echo -e "${BLUE}Attempting AI fix...${NC}"
        if fix_with_ai "$ERROR_MSG" "package.json" "node"; then
            # Retry build after fix
            if ! npm run build; then
                echo -e "${RED}Build failed even after AI fix attempt${NC}"
                exit 1
            fi
        else
            echo -e "${RED}AI fix failed${NC}"
            exit 1
        fi
    else
        echo -e "${RED}AI fix not available${NC}"
        echo -e "${RED}Build failed: $ERROR_MSG${NC}"
        exit 1
    fi
fi

# Add error pattern learning for common errors
learn_from_errors() {
    local output="$1"
    
    # Extract and learn from stylelint errors
    if echo "$output" | grep -q "stylelint-config-standard"; then
        add_pattern \
            "Could not find \"stylelint-config-standard\"" \
            "npm install --save-dev stylelint-config-standard" \
            1 \
            "{\"type\":\"dependency\",\"tool\":\"stylelint\"}"
    fi
    
    # Extract and learn from PHP errors
    if echo "$output" | grep -q "PHP syntax error"; then
        add_pattern \
            "$(echo "$output" | grep -A 1 "PHP syntax error")" \
            "phpcbf --standard=WordPress" \
            1 \
            "{\"type\":\"syntax\",\"language\":\"php\"}"
    fi
    
    # Extract and learn from JavaScript errors
    if echo "$output" | grep -q "error.*no-unused-vars\|error.*no-undef"; then
        add_pattern \
            "$(echo "$output" | grep -A 1 "error.*no-")" \
            "eslint --fix" \
            1 \
            "{\"type\":\"lint\",\"tool\":\"eslint\"}"
    fi
}

# Add error learning to the build process
if [ -n "$BUILD_OUTPUT" ]; then
    learn_from_errors "$BUILD_OUTPUT"
fi

# Create production build
mkdir -p dist/staynalive

# Copy theme files
cp -r {assets,inc,languages,parts,patterns,styles,templates,src} dist/staynalive/
cp {style.css,functions.php,theme.json,index.php} dist/staynalive/

# Validate copied files
for file in "${required_files[@]}"; do
    dist_file="dist/staynalive/$file"
    if [ ! -f "$dist_file" ]; then
        echo -e "${RED}Error: Failed to copy $file to distribution${NC}"
        exit 1
    fi
done

# Create zip file
cd dist
if ! zip -r staynalive.zip staynalive -x ".*" -x "__MACOSX"; then
    echo -e "${RED}Error: Failed to create zip file${NC}"
    cd ..
    exit 1
fi
cd ..

echo -e "${GREEN}Installation complete!${NC}"
echo -e "Theme zip created at: ${BLUE}dist/staynalive.zip${NC}"
echo -e "You can now install this theme in WordPress through:"
echo -e "1. WordPress Admin > Appearance > Themes > Add New > Upload Theme"
echo -e "2. Or copy the contents of ${BLUE}dist/staynalive${NC} to your wp-content/themes directory"

# Error tracking
ERRORS=()
WARNINGS=()

# AI error fixing function
fix_with_ai() {
    local error_msg="$1"
    local file="$2"
    
    echo -e "${BLUE}AI attempting to fix error in ${file}:${NC}"
    echo -e "${RED}${error_msg}${NC}"
    
    # Common error patterns and their fixes
    declare -A error_patterns=(
        ["Cannot find module"]=1
        ["Could not find \"stylelint-config-standard\""]=1
        ["Failed to load '@wordpress/scripts/config"]=1
        ["peer dependency conflict"]=1
        ["ERESOLVE"]=1
        ["ajv"]=1
        ["webpack"]=1
        ["babel"]=1
        ["postcss"]=1
        ["PHP Parse error"]=1
        ["PHP Fatal error"]=1
        ["PHP Notice"]=1
        ["PHP Warning"]=1
        ["npm ERR!"]=1
        ["composer.json does not exist"]=1
        ["Package phpunit/phpunit has requirements"]=1
        ["Failed to load config"]=1
        ["Missing dependencies"]=1
    )

    # Check if error matches any known patterns
    for pattern in "${!error_patterns[@]}"; do
        if [[ $error_msg == *"$pattern"* ]]; then
            echo -e "${YELLOW}Detected known issue: $pattern${NC}"
            
            # Automatic fix without asking permission for critical errors
            if [[ $pattern == "ajv" || $pattern == "ERESOLVE" ]]; then
                echo "Applying automatic fix for critical dependency issue..."
                rm -rf node_modules package-lock.json
                npm install --save-dev ajv@latest ajv-keywords@latest
                npm install --legacy-peer-deps --no-audit
                return 0
            fi
            
            # Ask for permission for non-critical fixes
            echo -e "${YELLOW}Would you like me to fix this issue? (y/n)${NC}"
            read -r proceed
            
            if [[ "$proceed" =~ ^[Yy]$ ]]; then
                case "$pattern" in
                    "Cannot find module")
                        local missing_module=$(echo "$error_msg" | grep -o "'.*'" | head -1 | tr -d "'")
                        npm install --save-dev "$missing_module"
                        ;;
                    "Could not find \"stylelint-config-standard\"")
                        npm install --save-dev stylelint-config-standard
                        # Update stylelint config
                        update_stylelint_config
                        ;;
                    "Failed to load '@wordpress/scripts/config")
                        npm install --save-dev @wordpress/scripts@latest
                        ;;
                    "peer dependency conflict"|"ERESOLVE")
                        resolve_dependency_conflicts
                        ;;
                esac
                return 0
            fi
        fi
    done

    # If no known pattern matched, try generic fixes
    generic_error_fix "$error_msg" "$file"
}

# Function to update stylelint config
update_stylelint_config() {
    cat > .stylelintrc.json << 'EOL'
{
    "extends": [
        "stylelint-config-standard",
        "@wordpress/stylelint-config"
    ],
    "rules": {
        "no-descending-specificity": null,
        "selector-class-pattern": null
    }
}
EOL
}

# Function to resolve dependency conflicts
resolve_dependency_conflicts() {
    echo "Resolving dependency conflicts..."
    rm -rf node_modules package-lock.json
    npm install --legacy-peer-deps --no-audit
    
    # Check for specific version conflicts
    if grep -q "stylelint" package.json; then
        npm install --save-dev stylelint@14.16.1
    fi
    
    if grep -q "@wordpress/stylelint-config" package.json; then
        npm install --save-dev @wordpress/stylelint-config@21.41.0
    fi
}

# Function for generic error fixes
generic_error_fix() {
    local error_msg="$1"
    local file="$2"

    if [ -f "$file" ]; then
        # Create backup
        cp "$file" "${file}.backup"
        
        # Basic fixes based on error patterns
        case "$error_msg" in
            *"syntax error"*) fix_syntax_error "$file" ;;
            *"undefined"*) fix_undefined_error "$file" ;;
            *"missing"*) fix_missing_error "$file" ;;
            *) 
                echo -e "${RED}Unable to automatically fix this error${NC}"
                mv "${file}.backup" "$file"
                return 1
                ;;
        esac
        
        # Verify fix
        verify_fix "$file"
    fi
}

# Modify error logging to attempt AI fixes
log_error() {
    local error_msg="$1"
    local file="$2"
    
    ERRORS+=("$error_msg")
    echo -e "${RED}Error: $error_msg${NC}"
    
    if [ -n "$file" ]; then
        fix_with_ai "$error_msg" "$file"
    fi
}

# Update error handling in commands
if ! npm install 2> npm-error.log; then
    log_error "Failed to install npm dependencies" "package.json"
fi

if ! composer install 2> composer-error.log; then
    log_error "Failed to install composer dependencies" "composer.json"
fi

# Add error handling for PHP files
for php_file in $(find . -name "*.php"); do
    if ! php -l "$php_file" > /dev/null 2>&1; then
        log_error "PHP syntax error in $php_file" "$php_file"
    fi
done

# Function to log warnings
log_warning() {
    WARNINGS+=("$1")
    echo -e "${YELLOW}Warning: $1${NC}"
}

# Function to display summary
display_summary() {
    echo -e "\n${BLUE}Build Summary:${NC}"
    # Performance metrics
    echo -e "\n${BLUE}Performance Metrics:${NC}"
    echo -e "Build time: $((SECONDS))s"
    echo -e "Memory usage: $(ps -o rss= -p $$)KB"
    
    # Test results
    echo -e "\n${BLUE}Test Results:${NC}"
    if [ -f "test-results.json" ]; then
        echo -e "Unit Tests: $(jq '.numPassedTests' test-results.json) passed"
        echo -e "E2E Tests: $(jq '.numPassedE2E' test-results.json) passed"
    fi
    
    # Error summary
    if [ ${#ERRORS[@]} -eq 0 ]; then
        echo -e "${GREEN}No errors found!${NC}"
    else
        echo -e "${RED}Found ${#ERRORS[@]} errors:${NC}"
        echo -e "\nError Details:"
        printf '%s\n' "${ERRORS[@]}"
    fi
    
    if [ ${#WARNINGS[@]} -gt 0 ]; then
        echo -e "${YELLOW}Found ${#WARNINGS[@]} warnings:${NC}"
        printf '%s\n' "${WARNINGS[@]}"
    fi
}

display_summary 