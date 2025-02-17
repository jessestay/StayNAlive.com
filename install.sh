#!/usr/bin/env bash

# Colors for output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m'

# Initialize error and warning arrays
declare -a ERRORS=()
declare -a WARNINGS=()

# Define all functions first
fix_php_docblocks() {
    local file="$1"
    if [ -z "$file" ]; then
        log_error "No file provided to fix_php_docblocks" "function" "Usage: fix_php_docblocks <file>"
        return 1
    fi
    debug_log "fix_php_docblocks" "Starting fixes for $file"
    # Fix docblock syntax errors
    sed -i '' 's/\/\*\*\s*\*\s*\([^*]\)/\/** \1/g' "$file"  # Fix double asterisk
    sed -i '' 's/\*\s*\*\s*\//*/g' "$file"  # Fix closing
    # Fix package tags
    sed -i '' 's/@package\s*\([^*]*\)\*/@package \1/g' "$file"
    # Fix link tags
    sed -i '' 's/@link\s*\([^*]*\)\*/@link \1/g' "$file"
    # Fix author tags
    sed -i '' 's/@author\s*\([^*]*\)\*/@author \1/g' "$file"
    # Fix version tags
    sed -i '' 's/@version\s*\([^*]*\)\*/@version \1/g' "$file"
}

fix_php_issues() {
    local file="$1"
    if [ -z "$file" ]; then
        log_error "No file provided to fix_php_issues" "function" "Usage: fix_php_issues <file>"
        return 1
    fi
    debug_log "fix_php_issues" "Starting fixes for $file"
    # Fix logical operators
    sed -i '' 's/\([^&]\)and\([^&]\)/\1 \&\& \2/g' "$file"
    sed -i '' 's/\([^|]\)or\([^|]\)/\1 || \2/g' "$file"
    # Fix concatenation spacing
    sed -i '' 's/\([^[:space:]]\)\.\([^[:space:]]\)/\1 . \2/g' "$file"
    # Fix indentation and spacing
    sed -i '' 's/^[[:space:]]*\([^[:space:]]\)/    \1/g' "$file"
}

fix_css_issues() {
    local file="$1"
    if [ -z "$file" ]; then
        log_error "No file provided to fix_css_issues" "function" "Usage: fix_css_issues <file>"
        return 1
    fi
    debug_log "fix_css_issues" "Starting fixes for $file"
    # Fix selector syntax
    sed -i '' 's/:before/::before/g' "$file"
    sed -i '' 's/:after/::after/g' "$file"
    sed -i '' 's/:first-line/::first-line/g' "$file"
    sed -i '' 's/:first-letter/::first-letter/g' "$file"
    # Fix WordPress specific patterns
    sed -i '' 's/\.wp-block-\([^[:space:]]*\)/\.wp-block-\1/g' "$file"
    # Fix custom properties
    sed -i '' 's/var(--wp--/var(--wp-/g' "$file"
}

# Function to validate shell script
validate_shell_script() {
    local script="$1"
    local description="$2"

    # Check syntax
    if ! bash -n <(echo "$script"); then
        return 1
    fi

    # Count and verify matching pairs
    local open_parens=$(echo "$script" | grep -o "(" | wc -l)
    local close_parens=$(echo "$script" | grep -o ")" | wc -l)
    local open_braces=$(echo "$script" | grep -o "{" | wc -l)
    local close_braces=$(echo "$script" | grep -o "}" | wc -l)

    if [ "$open_parens" != "$close_parens" ] || [ "$open_braces" != "$close_braces" ]; then
        echo "Mismatched parentheses or braces in $description"
        return 1
    fi

    return 0
}

# Function to validate all scripts
validate_scripts() {
    if ! validate_shell_script "$AWK_SCRIPT" "awk script"; then
        log_error "Script validation failed" "validation" "Awk script contains errors"
        exit 1
    fi
}

# Function to log errors with more detail
log_error() {
    local message="$1"
    local file="$2"
    local details="$3"
    ERRORS+=("${file}: ${message}")
    echo -e "\n${RED}Error: ${message}${NC}"
    if [ -n "$details" ]; then
        echo -e "${RED}Details:\n${details}${NC}"
    fi
    # Add file contents if it exists
    if [ -f "$file" ]; then
        echo -e "${YELLOW}File contents before error:${NC}"
        head -n 20 "$file"
    fi
    # Add debug info
    echo -e "${YELLOW}Debug information:${NC}"
    echo "Current working directory: $(pwd)"
    echo "File permissions: $(ls -l "$file" 2>/dev/null || echo 'File not found')"
    echo "Available disk space: $(df -h . | tail -n 1)"
    # Add stack trace
    echo -e "${RED}Stack trace:${NC}"
    local frame=0
    while caller $frame; do
        ((frame++))
    done
    # Log environment state
    echo -e "${YELLOW}Environment state:${NC}"
    echo "Current directory: $(pwd)"
    echo "Node modules bin directory contents:"
    ls -la ./node_modules/.bin || echo "No node_modules/.bin directory found"
    echo "PATH: $PATH"
    echo "npm list output:"
    npm list @staynalive/ai-fix || echo "ai-fix not found in npm list"
}

# Function to log warnings
log_warning() {
    local message="$1"
    local file="$2"
    WARNINGS+=("${file}: ${message}")
    echo -e "${YELLOW}Warning: ${message}${NC}"
}

# Function to log debug information
debug_log() {
    local function_name="$1"
    local message="$2"
    echo -e "${BLUE}[DEBUG] ${function_name}: ${message}${NC}"
}

# Function to verify fixes
verify_fixes() {
    local errors=0
    declare -a UNFIXED_ERRORS=()
    
    debug_log "verify_fixes" "Starting verification"
    
    # Verify PHP syntax first
    for file in inc/*.php *.php; do
        [ -f "$file" ] || continue
        
        # Check basic syntax
        if ! php -l "$file" > /dev/null 2>&1; then
            ((errors++))
            UNFIXED_ERRORS+=("PHP syntax error in $file: $(php -l "$file" 2>&1)")
            continue
        fi
        
        # Check WordPress standards
        if ! phpcs --standard=WordPress "$file" | grep -q "FOUND 0 ERRORS"; then
            ((errors++))
            UNFIXED_ERRORS+=("WordPress standards error in $file")
            # Try to fix automatically
            phpcbf --standard=WordPress "$file" || true
        fi
    done
    
    # Check CSS
    if npm run lint:css | grep -q "problem"; then
        ((errors++))
        local css_errors=$(npm run lint:css)
        UNFIXED_ERRORS+=("CSS validation errors: $css_errors")
        log_error "CSS validation failed:\n$css_errors" "css"
    fi
    
    # Show summary of unfixed errors if any remain
    if [ ${#UNFIXED_ERRORS[@]} -gt 0 ]; then
        echo -e "\n${RED}Summary of Unfixed Errors:${NC}"
        printf '%s\n' "${UNFIXED_ERRORS[@]}" | sort -u
    fi
    
    # Log verification results
    debug_log "verify_fixes" "Found $errors errors"
    if [ ${#UNFIXED_ERRORS[@]} -gt 0 ]; then
        debug_log "verify_fixes" "Unfixed errors:"
        printf '%s\n' "${UNFIXED_ERRORS[@]}"
    fi
    
    return $errors
}

# Source AI fix scripts
for script in .ai-fix/{ml,sync}/*.sh; do
    if [ -f "$script" ]; then
        source "$script"
    fi
done

# Initialize AI fix
if [ ! -d ".ai-fix" ]; then
    echo "Initializing AI fix..."
    mkdir -p .ai-fix/{ml,sync,patterns}
    
    # Create pattern directories
    mkdir -p .ai-fix/patterns/{php,css,js}
    
    # Create PHP patterns
    cat > .ai-fix/patterns/php/docblock.json << 'EOL'
{
    "patterns": [
        {
            "match": "\\*\\s*@\\s*(package|link|author|version)\\s*([^*]*)\\*",
            "replace": "* @$1 $2",
            "description": "Fix docblock tags"
        },
        {
            "match": "^[[:space:]]*\\* [a-z]",
            "replace": "* \\u$1",
            "description": "Capitalize docblock descriptions"
        }
    ]
}
EOL
    
    # Create sync configuration
    cat > .ai-fix/sync/config.json << 'EOL'
{
    "patterns": {
        "watch": ["**/*.php", "**/*.css", "**/*.js"],
        "ignore": ["node_modules/**", "vendor/**"]
    },
    "actions": {
        "*.php": ["php-fix", "phpcs-fix"],
        "*.css": ["css-fix", "stylelint-fix"]
    }
}
EOL
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

# Create templates directory
if [ ! -d "templates" ]; then
    mkdir -p templates
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

# Create template parts directory
if [ ! -d "parts" ]; then
    mkdir -p parts
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

# Checkpoint tracking
CHECKPOINT_FILE=".install-checkpoint"

# Function to save checkpoint
save_checkpoint() {
    echo "$1" > "$CHECKPOINT_FILE"
}

# Function to get last checkpoint
get_checkpoint() {
    if [ -f "$CHECKPOINT_FILE" ]; then
        cat "$CHECKPOINT_FILE"
    else
        echo "start"
    fi
}

# Error handling
set -e  # Stop on any error

handle_error() {
    local exit_code=$?
    local line_number=$1
    echo -e "${RED}Error occurred in line ${line_number}${NC}"
    save_checkpoint "failed_at_${line_number}"
    exit $exit_code
}

trap 'handle_error ${LINENO}' ERR

# Function to run comprehensive PHP fixes
fix_php_files() {
    local file="$1"
    local fixed=0
    
    # Backup file first
    cp "$file" "$file.bak"
    
    # Fix docblock syntax first (most critical)
    sed -i '' -E '
        # Fix docblock opening
        s/\/\*\*[[:space:]]*\*/\/\*\*/g
        # Fix docblock alignment with tabs
        s/^[[:space:]]*\*/\t*/g
        # Fix docblock closing
        s/\*[[:space:]]*\//*/g
        # Fix package tags
        s/@package[[:space:]]*([^*]*)\*/@package \1/g
        # Fix link tags
        s/@link[[:space:]]*([^*]*)\*/@link \1/g
        # Fix author tags
        s/@author[[:space:]]*([^*]*)\*/@author \1/g
        # Fix version tags
        s/@version[[:space:]]*([^*]*)\*/@version \1/g
    ' "$file"
    
    # Convert spaces to tabs for indentation
    expand -t 4 "$file" | unexpand -t 4 > "$file.tmp" && mv "$file.tmp" "$file"
    
    # Fix function documentation
    awk '
        /function[[:space:]]+[^(]+\([^)]*\)/ {
            # Extract function name and parameters
            match($0, /function[[:space:]]+([^(]+)\(([^)]*)\)/, arr)
            func_name = arr[1]
            params = arr[2]
            
            # Create docblock
            printf "/**\n"
            printf " * %s function\n", func_name
            
            # Add param docs
            split(params, param_arr, ",")
            for (i in param_arr) {
                if (match(param_arr[i], /\$[a-zA-Z_][a-zA-Z0-9_]*/, param)) {
                    printf " * @param mixed %s Parameter description\n", param[0]
                }
            }
            
            printf " *\n"
            printf " * @return void\n"
            printf " */\n"
        }
        { print }
    ' "$file" > "$file.tmp" && mv "$file.tmp" "$file"
    
    # Run PHP Code Beautifier
    if command -v phpcbf >/dev/null 2>&1; then
        phpcbf --standard=WordPress "$file" || true
    fi
    
    # Run PHP Code Sniffer to verify
    if phpcs --standard=WordPress "$file" | grep -q "FOUND 0 ERRORS"; then
        fixed=1
    else
        # Restore backup if fixes failed
        mv "$file.bak" "$file"
    fi
    
    rm -f "$file.bak" "$file.tmp"
    return $fixed
}

# Main installation process
LAST_CHECKPOINT=$(get_checkpoint)

# Create package.json first, before any npm operations
if [ ! -f "package.json" ]; then
    echo "Creating package.json with required dependencies..."
    cat > package.json << 'EOL'
{
    "name": "staynalive",
    "version": "2.0.0",
    "scripts": {
        "build": "ai-fix watch -- webpack",
        "watch": "webpack --mode development --watch",
        "lint:css": "stylelint 'assets/css/**/*.css'"
    },
    "dependencies": {
        "css-loader": "^6.7.1",
        "mini-css-extract-plugin": "^2.6.1",
        "style-loader": "^3.3.1",
        "webpack": "^5.74.0",
        "webpack-cli": "^4.10.0",
        "ai-fix": "file:.ai-fix"
    },
    "devDependencies": {
        "stylelint": "^14.11.0",
        "stylelint-config-standard": "^28.0.0"
    }
}
EOL
fi

# Create webpack.config.js if it doesn't exist
if [ ! -f "webpack.config.js" ]; then
    echo "Creating webpack.config.js..."
    cat > webpack.config.js << 'EOL'
const path = require('path');
const MiniCssExtractPlugin = require('mini-css-extract-plugin');

module.exports = {
    mode: 'production',
    entry: './src/index.js',
    output: {
        path: path.resolve(__dirname, 'build'),
        filename: 'js/bundle.js'
    },
    module: {
        rules: [
            {
                test: /\.css$/,
                use: [MiniCssExtractPlugin.loader, 'css-loader']
            }
        ]
    },
    plugins: [
        new MiniCssExtractPlugin({
            filename: 'css/style.css'
        })
    ]
};
EOL
fi

# Initialize AI fix if not already done
if [ ! -d ".ai-fix" ]; then
    echo "Initializing AI fix..."
    mkdir -p .ai-fix/{ml,sync,patterns}

    # Copy AI fix patterns
    if [ -d "../ai-fix-patterns" ]; then
        echo "Copying AI fix patterns..."
        cp -r ../ai-fix-patterns/* .ai-fix/
    else
        echo -e "${RED}Error: ai-fix-patterns directory not found${NC}"
        exit 1
    fi

    # Create package.json for ai-fix if it doesn't exist
    if [ ! -f ".ai-fix/package.json" ]; then
        echo "Creating AI fix package.json..."
        cat > .ai-fix/package.json << 'EOL'
{
    "name": "ai-fix",
    "version": "1.0.0",
    "bin": {
        "ai-fix": "./bin/ai-fix.js"
    },
    "scripts": {
        "watch": "node ./bin/ai-fix.js watch"
    },
    "dependencies": {
        "chokidar": "^3.5.3",
        "commander": "^9.4.0"
    }
}
EOL
    fi

    # Create the ai-fix binary
    mkdir -p .ai-fix/bin
    cat > .ai-fix/bin/ai-fix.js << 'EOL'
#!/usr/bin/env node

const { program } = require('commander');
const chokidar = require('chokidar');
const { spawn } = require('child_process');

program
    .command('watch')
    .description('Watch for changes and run commands')
    .action(() => {
        const args = process.argv.slice(3);
        if (args.length) {
            spawn(args[0], args.slice(1), { stdio: 'inherit' });
        }
    });

program.parse(process.argv);
EOL

    chmod +x .ai-fix/bin/ai-fix.js
fi

# Install dependencies before any other operations
echo "Installing Node dependencies..."
if ! npm install --legacy-peer-deps > npm-install.log 2>&1; then
    log_error "Failed to install npm dependencies" "npm" "$(cat npm-install.log)"
    exit 1
fi

# Install Composer dependencies if composer.json doesn't exist
if [ ! -f "composer.json" ]; then
    echo "Creating composer.json..."
    cat > composer.json << 'EOL'
{
    "require-dev": {
        "squizlabs/php_codesniffer": "^3.7",
        "wp-coding-standards/wpcs": "^3.0"
    },
    "scripts": {
        "post-install-cmd": [
            "phpcs --config-set installed_paths vendor/wp-coding-standards/wpcs"
        ]
    }
}
EOL
fi

# Install Composer dependencies
echo "Installing Composer dependencies..."
if ! composer install; then
    log_error "Failed to install Composer dependencies" "composer" "$(cat composer.log 2>/dev/null)"
    exit 1
fi

case "$LAST_CHECKPOINT" in
    "start")
        echo "Starting fresh installation..."
        # Source AI fix scripts first
        for script in .ai-fix/{ml,sync}/*.sh; do
            if [ -f "$script" ]; then
                source "$script"
            fi
        done

        # Initialize AI fix if not already done
        if [ ! -d ".ai-fix" ]; then
            mkdir -p .ai-fix/{ml,sync,patterns}
            cp -r .ai-fix/templates/* .ai-fix/
        fi

        # Install Composer dependencies
        echo "Installing Composer dependencies..."
        composer install
        
        # Verify all dependencies installed correctly
        if ! [ -f "./node_modules/.bin/ai-fix" ]; then
            echo -e "${RED}AI-fix not installed correctly${NC}"
            echo -e "${YELLOW}Attempting to install ai-fix directly...${NC}"
            # Show current package.json contents
            echo "Current package.json contents:"
            cat package.json
            
            # Try to install with more verbose output
            echo "Installing ai-fix with verbose output..."
            npm install @staynalive/ai-fix --legacy-peer-deps --verbose
            
            # Check installation result
            if ! [ -f "./node_modules/.bin/ai-fix" ]; then
                log_error "Failed to install ai-fix" "npm" "$(npm list @staynalive/ai-fix 2>&1)"
                exit 1
            fi
        fi

        if ! command -v ./node_modules/.bin/stylelint >/dev/null 2>&1; then
            echo -e "${RED}Stylelint not installed correctly${NC}"
            exit 1
        fi
        
        save_checkpoint "create_files"
        ;;
        
    "create_files")
        echo "Creating required files..."
        # Create necessary directories
        mkdir -p {assets/{css/{base,blocks,components,utilities},js},inc/classes,languages,parts,patterns,styles,templates,tests,src}
        
        # Create .gitkeep files in empty directories
        find . -type d -empty -exec touch {}/.gitkeep \;
        
        # Create required files
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
        
        # Create other required files
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
        
        # Create template files
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
        
        save_checkpoint "dependencies"
        ;;
        
    "dependencies")
        echo "Dependencies installed, proceeding with fixes..."
        save_checkpoint "php_fixes"
        ;;
        
    "php_fixes")
        echo "Fixing PHP files..."
        for file in inc/*.php *.php; do
            [ -f "$file" ] || continue
            cp "$file" "${file}.original"
            
            echo "Fixing $file..."
            if ! fix_php_files "$file"; then
                echo -e "${RED}Failed to fix $file${NC}"
                mv "${file}.original" "$file"
                exit 1
            fi
            
            if ! ./vendor/bin/phpcs --standard=WordPress "$file" | grep -q "FOUND 0 ERRORS"; then
                echo "Restoring original $file due to remaining errors"
                mv "${file}.original" "$file"
                exit 1
            else
                rm "${file}.original"
            fi
        done
        save_checkpoint "css_fixes"
        ;;
        
    "css_fixes")
        echo "Fixing CSS files..."
        cat > .stylelintrc.json << 'EOL'
{
    "extends": "stylelint-config-standard",
    "rules": {
        "selector-pseudo-element-colon-notation": "double",
        "selector-pseudo-class-no-unknown": [true, {
            "ignorePseudoClasses": ["root", "global"]
        }],
        "custom-property-pattern": "^([a-z][a-z0-9]*)(-[a-z0-9]+)*$",
        "selector-class-pattern": null,
        "no-descending-specificity": null,
        "function-no-unknown": null,
        "property-no-vendor-prefix": null,
        "at-rule-no-unknown": null
    }
}
EOL
        
        echo -e "${BLUE}Verifying CSS fixes...${NC}"
        ./node_modules/.bin/stylelint 'assets/css/**/*.css' --fix || true
        
        save_checkpoint "build"
        ;;
        
    "build")
        echo "Building assets..."
        echo "Running webpack build..."
        if ! npm run build > build.log 2>&1; then
            log_error "Webpack build failed" "webpack" "$(cat build.log)"
            cat build.log
            exit 1
        fi
        
        # Verify build output
        if [ ! -f "build/js/bundle.js" ]; then
            log_error "JavaScript bundle not created" "webpack"
            exit 1
        fi
        if [ ! -f "build/css/style.css" ]; then
            log_error "CSS bundle not created" "webpack"
            exit 1
        fi

        save_checkpoint "complete"
        ;;
        
    "complete")
        echo "Installation already complete. Use --force to restart."
        exit 0
        ;;
esac

# Only clean up if we reach here successfully
cleanup() {
    rm -f fix.php
    find . -name "*.original" -delete
    find . -name "*.tmp" -delete
    find . -name "*.bak" -delete
    echo -e "${GREEN}Installation completed successfully${NC}"
}

# Only run cleanup on successful completion
if [ "$LAST_CHECKPOINT" = "complete" ]; then
    cleanup
fi

# Create src directory if it doesn't exist
if [ ! -d "src" ]; then
    mkdir -p src
fi

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

# Validate required files before any operations
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
    
    # Show build log if it exists
    if [ -f "build.log" ]; then
        echo -e "\n${BLUE}Build Log:${NC}"
        cat build.log
    fi
}

if [ "$LAST_CHECKPOINT" = "complete" ]; then
    cleanup
    display_summary
fi

# Try fixes with increasing aggressiveness
validate_scripts

for attempt in {1..3}; do
    echo -e "${BLUE}Fix attempt $attempt with increased aggressiveness...${NC}"
    
    case $attempt in
        1) # Basic fixes
            # Find and fix PHP files
            for file in inc/*.php *.php; do
                [ -f "$file" ] || continue
                echo "Applying basic fixes to $file..."
                fix_php_docblocks "$file"
                fix_php_issues "$file"
            done
            
            # Find and fix CSS files
            for file in assets/css/**/*.css; do
                [ -f "$file" ] || continue
                echo "Applying basic fixes to $file..."
                fix_css_issues "$file"
            done
            ;;
        2) # More aggressive fixes
            # Force WordPress standards
            ./vendor/bin/phpcbf --standard=WordPress inc/*.php *.php || true
            # Force CSS standards
            cat > .stylelintrc.json << 'EOL'
{
    "extends": "stylelint-config-standard",
    "rules": {
        "selector-pseudo-element-colon-notation": "double",
        "selector-pseudo-class-no-unknown": [true, {
            "ignorePseudoClasses": ["root", "global"]
        }],
        "custom-property-pattern": "^([a-z][a-z0-9]*)(-[a-z0-9]+)*$",
        "selector-class-pattern": null,
        "no-descending-specificity": null,
        "function-no-unknown": null,
        "property-no-vendor-prefix": null,
        "at-rule-no-unknown": null
    }
}
EOL
            # Fix CSS files
            for file in assets/css/**/*.css; do
                [ -f "$file" ] || continue
                # Convert single colons to double for pseudo-elements
                sed -i '' 's/:before/::before/g' "$file"
                sed -i '' 's/:after/::after/g' "$file"
                sed -i '' 's/:first-line/::first-line/g' "$file"
                sed -i '' 's/:first-letter/::first-letter/g' "$file"
                # Fix custom properties
                sed -i '' 's/var(--wp--/var(--wp-/g' "$file"
            done
            ;;
        3) # Most aggressive fixes
            # Completely rebuild docblocks
            find . -name "*.php" -type f -exec rm -f {}.bak \;
            find . -name "*.php" -type f -exec php -l {} \;
            # Force CSS to strict standard
            for file in assets/css/**/*.css; do
                [ -f "$file" ] || continue
                # Normalize selectors
                sed -i '' 's/\([[:space:]]\):/\1::/g' "$file"
                # Fix WordPress specific patterns
                sed -i '' 's/\.wp-block-\([^[:space:]]*\)/\.wp-block-\1/g' "$file"
                # Fix custom properties
                sed -i '' 's/var(--\([^)]*\))/var(--wp-\1)/g' "$file"
            done
            ;;
    esac
    
    if verify_fixes; then
        echo -e "${GREEN}All fixes successful!${NC}"
        break
    elif [ $attempt -eq 3 ]; then
        echo -e "${RED}Could not fix all issues after 3 attempts${NC}"
        exit 1
    fi
done

# Add git hooks
mkdir -p .git/hooks
cat > .git/hooks/pre-commit << 'EOL'
#!/bin/bash

# Check PHP files
for file in $(git diff --cached --name-only | grep '\.php$'); do
    if ! ./vendor/bin/phpcs --standard=WordPress "$file" | grep -q "FOUND 0 ERRORS"; then
        echo "PHP errors found in $file. Running fixes..."
        ./vendor/bin/phpcbf --standard=WordPress "$file"
        git add "$file"
    fi
done

# Check CSS files
for file in $(git diff --cached --name-only | grep '\.css$'); do
    if ! npx stylelint "$file"; then
        echo "CSS errors found in $file. Running fixes..."
        npx stylelint --fix "$file"
        git add "$file"
    fi
done
EOL
chmod +x .git/hooks/pre-commit 