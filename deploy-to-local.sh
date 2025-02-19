#!/usr/bin/env bash

# Colors for output
readonly GREEN='\033[0;32m'
readonly RED='\033[0;31m'
readonly YELLOW='\033[0;33m'
readonly NC='\033[0m'

# Detect OS and set paths accordingly
if [[ "$OSTYPE" == "msys" || "$OSTYPE" == "cygwin" ]]; then
    # Windows paths
    # Convert Windows path to MINGW format
    readonly LOCAL_ROOT="/c/Users/$USERNAME/Local Sites"
else
    # Mac/Linux paths
    readonly LOCAL_ROOT="$HOME/Local Sites"
fi

# Find available Local sites
echo "Available Local sites:"
if [[ "$OSTYPE" == "msys" || "$OSTYPE" == "cygwin" ]]; then
    ls -1 "$LOCAL_ROOT" 2>/dev/null || {
        echo -e "${RED}Error: No Local sites found in $LOCAL_ROOT${NC}"
        echo "Looking in: $LOCAL_ROOT"
        exit 1
    }
else
    ls -1 "$LOCAL_ROOT" 2>/dev/null || {
        echo -e "${RED}Error: No Local sites found in $LOCAL_ROOT${NC}"
        exit 1
    }
fi

# Modify the site selection prompt
read -p "Enter Local site name [staynalive]: " SITE_NAME
SITE_NAME=${SITE_NAME:-staynalive}

# Set paths based on OS
if [[ "$OSTYPE" == "msys" || "$OSTYPE" == "cygwin" ]]; then
    readonly LOCAL_PATH="$LOCAL_ROOT/$SITE_NAME/app/public/wp-content/themes"
else
    readonly LOCAL_PATH="$LOCAL_ROOT/$SITE_NAME/app/public/wp-content/themes"
fi

# Theme details
readonly THEME_DIR="stay-n-alive"
readonly THEME_ZIP="stay-n-alive.zip"

# Helper function to run PowerShell commands
run_powershell() {
    local command="$1"
    local error_msg="${2:-PowerShell command failed}"
    
    if ! command -v powershell.exe >/dev/null 2>&1; then
        echo -e "${RED}Error: PowerShell is not available${NC}"
        return 1
    fi
    
    powershell.exe -Command "
        \$ErrorActionPreference = 'Stop'
        try {
            $command
        }
        catch {
            Write-Host \"ERROR: \$_\"
            exit 1
        }
    " || {
        echo -e "${RED}Error: $error_msg${NC}"
        return 1
    }
    
    return 0
}

# Verify Local site exists
if [[ ! -d "$LOCAL_PATH" ]]; then
    echo -e "${RED}Error: Local site not found at $LOCAL_PATH${NC}"
    exit 1
fi

# Modify the continue prompt
read -p "Continue? [Y/n] " -n 1 -r REPLY
echo
REPLY=${REPLY:-Y}
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "Deployment cancelled"
    exit 1
fi

# Add near the top of the script
backup_theme() {
    local theme_dir="$1"
    local backup_name="${theme_dir}_backup_$(date +%Y%m%d_%H%M%S)"
    
    if [[ -d "$LOCAL_PATH/$theme_dir" ]]; then
        echo "Creating backup of existing theme..."
        mv "$LOCAL_PATH/$theme_dir" "$LOCAL_PATH/$backup_name" || {
            echo -e "${RED}Error: Could not create backup${NC}"
            return 1
        }
        echo "Backup created at: $backup_name"
    fi
    return 0
}

# Modify the theme existence prompt
if [[ -d "$LOCAL_PATH/$THEME_DIR" ]]; then
    echo -e "${YELLOW}Theme directory already exists${NC}"
    read -p "Do you want to (O)verwrite, (B)ackup and overwrite, or (C)ancel? [O/b/c]: " choice
    choice=${choice:-O}
    case "${choice^^}" in
        O*)
            rm -rf "$LOCAL_PATH/$THEME_DIR"
            ;;
        B*)
            backup_theme "$THEME_DIR" || exit 1
            ;;
        *)
            echo "Deployment cancelled"
            exit 0
            ;;
    esac
fi

# Create theme directory
mkdir -p "$LOCAL_PATH/$THEME_DIR" || {
    echo -e "${RED}Error: Could not create theme directory${NC}"
    exit 1
}

# Deploy theme
echo "Deploying theme to Local..."
echo "DEBUG: Current directory: $(pwd)"
echo "DEBUG: Theme zip exists: $([[ -f "$THEME_ZIP" ]] && echo "Yes" || echo "No")"
echo "DEBUG: Theme zip size: $(stat -f%z "$THEME_ZIP" 2>/dev/null || stat -c%s "$THEME_ZIP" 2>/dev/null || echo "unknown")"

# Use PowerShell for extraction on Windows
if [[ "$OSTYPE" == "msys" || "$OSTYPE" == "cygwin" ]]; then
    echo "DEBUG: Using PowerShell to extract zip"
    run_powershell "
        Write-Host \"DEBUG: PowerShell - Zip file path: $THEME_ZIP\"
        Write-Host \"DEBUG: PowerShell - Destination path: $LOCAL_PATH/$THEME_DIR\"
        \$ErrorActionPreference = 'Stop'
        # Convert Unix-style path to Windows path
        \$destPath = '$LOCAL_PATH/$THEME_DIR' -replace '^/c/', 'C:/' -replace '/', '\\'
        Write-Host \"DEBUG: PowerShell - Converted destination path: \$destPath\"
        Expand-Archive -Path '$THEME_ZIP' -DestinationPath \$destPath -Force
        Write-Host \"DEBUG: PowerShell - Extraction complete\"
        Get-ChildItem -Path \$destPath -Recurse | Select-Object FullName
    " || {
        echo -e "${RED}Error: Could not extract theme to Local${NC}"
        exit 1
    }
else
    unzip -o "$THEME_ZIP" -d "$LOCAL_PATH/$THEME_DIR" || {
        echo -e "${RED}Error: Could not extract theme to Local${NC}"
        exit 1
    }
fi

# Verify extraction
if [[ ! -f "$LOCAL_PATH/$THEME_DIR/style.css" ]]; then
    echo -e "${RED}Error: Could not extract theme to Local${NC}"
    exit 1
fi

# Add this function for consistent error logging
log_error() {
    local message="$1"
    local file="$2"
    local function_name="${FUNCNAME[1]}"
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    
    echo -e "${RED}[$timestamp] ERROR in $function_name: $message${NC}"
    
    if [[ -n "$file" && -f "$file" ]]; then
        echo "File contents at time of error:"
        head -n 20 "$file"
        echo "..."
        tail -n 20 "$file"
    fi
}

verify_functions_php() {
    echo "Verifying functions.php..."
    
    if [[ ! -f "$LOCAL_PATH/$THEME_DIR/functions.php" ]]; then
        log_error "functions.php not found"
        return 1
    fi
    
    # Create backup
    cp "$LOCAL_PATH/$THEME_DIR/functions.php" "$LOCAL_PATH/$THEME_DIR/functions.php.bak" || {
        log_error "Failed to create backup of functions.php"
        return 1
    }
    
    # Update functions.php
    cat > "$LOCAL_PATH/$THEME_DIR/functions.php" << 'EOL'
<?php
/**
 * Theme functions and definitions
 *
 * @package Stay_N_Alive
 */

if ( ! defined( 'ABSPATH' ) ) {
    exit; // Exit if accessed directly
}

// Define theme constants
define( 'STAY_N_ALIVE_VERSION', '1.0.0' );
define( 'STAY_N_ALIVE_DIR', get_template_directory() );
define( 'STAY_N_ALIVE_URI', get_template_directory_uri() );

// Load core theme files - order matters!
require_once STAY_N_ALIVE_DIR . '/inc/theme-setup.php';     // Basic theme setup
require_once STAY_N_ALIVE_DIR . '/inc/template-loader.php'; // Template loading
require_once STAY_N_ALIVE_DIR . '/inc/block-patterns.php';  // Block patterns
require_once STAY_N_ALIVE_DIR . '/inc/security.php';        // Security features
require_once STAY_N_ALIVE_DIR . '/inc/performance.php';     // Performance optimizations
require_once STAY_N_ALIVE_DIR . '/inc/social-feeds.php';    // Social media features
EOL
    
    # Log after update
    echo "Verifying functions.php after update:"
    grep "require_once" "$LOCAL_PATH/$THEME_DIR/functions.php" || {
        log_error "Failed to verify functions.php contents after update"
        return 1
    }
    
    return 0
}

# Function definitions
check_wp_cli() {
    if ! command -v wp >/dev/null 2>&1; then
        echo -e "${RED}Warning: wp-cli is not installed. Skipping theme check and activation.${NC}"
        echo "To install wp-cli:"
        echo "1. Visit: https://wp-cli.org/#installing"
        echo "2. Follow the installation instructions for your system"
        return 1
    fi
    return 0
}

run_theme_check() {
    if check_wp_cli; then
        echo "Running theme check..."
        if ! wp theme check "$THEME_DIR" --path="$LOCAL_PATH/../.."; then
            echo -e "${RED}Warning: Theme check found issues${NC}"
        fi
    fi
}

activate_theme() {
    if check_wp_cli; then
        echo "Activating theme..."
        if ! wp theme activate "$THEME_DIR" --path="$LOCAL_PATH/../.."; then
            echo -e "${RED}Error: Could not activate theme${NC}"
            return 1
        fi
    fi
    return 0
}

verify_theme_files() {
    echo "Verifying theme file structure..."
    local required_files=(
        "style.css"
        "index.php"
        "functions.php"
        "theme.json"
        "inc/block-patterns.php"
        "inc/theme-setup.php"
    )
    
    for file in "${required_files[@]}"; do
        if [[ ! -f "$LOCAL_PATH/$THEME_DIR/$file" ]]; then
            echo -e "${RED}Error: Missing required theme file: $file${NC}"
            return 1
        fi
    done
    
    # Verify theme setup is properly included
    if ! grep -q "require_once.*theme-setup.php" "$LOCAL_PATH/$THEME_DIR/functions.php"; then
        echo "Adding theme setup include to functions.php..."
        echo "require_once get_template_directory() . '/inc/theme-setup.php';" >> "$LOCAL_PATH/$THEME_DIR/functions.php"
    fi
    
    return 0
}

verify_theme_functions() {
    echo "Verifying theme function definitions..."
    
    # Create block-patterns.php if it doesn't exist
    if [[ ! -f "$LOCAL_PATH/$THEME_DIR/inc/block-patterns.php" ]]; then
        mkdir -p "$LOCAL_PATH/$THEME_DIR/inc"
        touch "$LOCAL_PATH/$THEME_DIR/inc/block-patterns.php"
    fi
    
    # First, backup the original file
    if [[ -f "$LOCAL_PATH/$THEME_DIR/inc/block-patterns.php" ]]; then
        cp "$LOCAL_PATH/$THEME_DIR/inc/block-patterns.php" "$LOCAL_PATH/$THEME_DIR/inc/block-patterns.php.bak"
    fi
    
    echo "Updating block patterns registration..."
    cat > "$LOCAL_PATH/$THEME_DIR/inc/block-patterns.php" << 'EOL'
<?php
/**
 * Block Patterns
 *
 * @package Stay_N_Alive
 */

if ( ! defined( 'ABSPATH' ) ) {
    exit; // Exit if accessed directly
}

if ( ! function_exists( 'stay_n_alive_register_block_patterns' ) ) {
    /**
     * Register block patterns and categories.
     *
     * @since 1.0.0
     */
    function stay_n_alive_register_block_patterns() {
        // Check for required functions
        if ( ! function_exists( 'register_block_pattern_category' ) || 
             ! function_exists( 'register_block_pattern' ) ) {
            return;
        }

        // Register block pattern category
        register_block_pattern_category(
            'stay-n-alive',
            array( 'label' => esc_html__( 'Stay N Alive', 'stay-n-alive' ) )
        );

        // Register block patterns
        $patterns = array(
            'author-bio' => array(
                'title' => esc_html__('Author Bio', 'stay-n-alive'),
                'description' => esc_html__('Author biography section', 'stay-n-alive'),
            ),
            'bio-link-button' => array(
                'title' => esc_html__('Bio Link Button', 'stay-n-alive'),
                'description' => esc_html__('A button for biography links', 'stay-n-alive'),
            ),
            'social-grid' => array(
                'title' => esc_html__('Social Grid', 'stay-n-alive'),
                'description' => esc_html__('A grid of social media links', 'stay-n-alive'),
            ),
        );

        foreach ( $patterns as $pattern_name => $pattern_info ) {
            $pattern_file = get_theme_file_path( "/patterns/{$pattern_name}.html" );
            
            if ( file_exists( $pattern_file ) ) {
                register_block_pattern(
                    'stay-n-alive/' . $pattern_name,
                    array_merge(
                        $pattern_info,
                        array(
                            'categories' => array( 'stay-n-alive' ),
                            'content' => file_get_contents( $pattern_file ),
                        )
                    )
                );
            }
        }
    }
}

// Hook into both init and after_setup_theme for maximum compatibility
add_action( 'init', 'stay_n_alive_register_block_patterns' );
add_action( 'after_setup_theme', 'stay_n_alive_register_block_patterns' );
EOL

    # Verify functions.php includes block-patterns.php
    if ! grep -q "require_once.*block-patterns.php" "$LOCAL_PATH/$THEME_DIR/functions.php"; then
        echo "Adding block patterns include to functions.php..."
        # Add after the last require_once
        sed -i '$ a\require_once get_template_directory() . '"'/inc/block-patterns.php';" "$LOCAL_PATH/$THEME_DIR/functions.php"
    fi
}

# Add this function near the other function definitions
debug_wordpress_theme() {
    local theme_dir="$1"
    echo "Performing WordPress theme debug checks..."
    
    # Check functions.php loading
    echo "Checking functions.php includes..."
    if [[ -f "$LOCAL_PATH/$theme_dir/functions.php" ]]; then
        echo "functions.php contents:"
        grep "require\|include" "$LOCAL_PATH/$theme_dir/functions.php"
    fi
    
    # Check block-patterns.php
    echo "Checking block-patterns.php..."
    if [[ -f "$LOCAL_PATH/$theme_dir/inc/block-patterns.php" ]]; then
        echo "block-patterns.php contents:"
        head -n 20 "$LOCAL_PATH/$theme_dir/inc/block-patterns.php"
        echo "Checking function registration:"
        grep -A 5 "function stay_n_alive_register_block_patterns" "$LOCAL_PATH/$theme_dir/inc/block-patterns.php"
        echo "Checking action hook:"
        grep "add_action" "$LOCAL_PATH/$theme_dir/inc/block-patterns.php"
    fi
    
    # Check theme setup
    echo "Checking theme setup..."
    if [[ -f "$LOCAL_PATH/$theme_dir/inc/theme-setup.php" ]]; then
        echo "theme-setup.php hooks:"
        grep "add_action\|add_filter" "$LOCAL_PATH/$theme_dir/inc/theme-setup.php"
    fi
    
    # Check WordPress debug log for specific errors
    echo "Checking WordPress debug log for block pattern errors..."
    if [[ -f "$LOCAL_PATH/../../wp-content/debug.log" ]]; then
        echo "Recent block pattern related errors:"
        grep -i "block_pattern\|stay_n_alive" "$LOCAL_PATH/../../wp-content/debug.log" | tail -n 10
    fi
}

# Modify the check_wordpress_health function to include more detailed error reporting
check_wordpress_health() {
    local site_url="$1"
    echo "Checking WordPress site health..."
    
    # Add debug headers to curl request with timeout
    echo "Testing homepage with debug headers..."
    if ! curl -sSf --max-time 10 -D - "http://${site_url}" > /dev/null 2>&1; then
        local curl_exit=$?
        echo -e "${RED}Error: Cannot access homepage at http://${site_url}${NC}"
        
        case $curl_exit in
            6)  echo "Could not resolve host: DNS lookup failed"
                echo "Check your hosts file or Local by Flywheel DNS settings"
                ;;
            7)  echo "Failed to connect: Local by Flywheel might not be running"
                echo "Start Local by Flywheel and ensure the site is running"
                ;;
            28) echo "Connection timed out after 10 seconds"
                echo "Site might be loading too slowly or not responding"
                ;;
            *)  echo "Curl error code: $curl_exit"
                ;;
        esac
        
        echo "Checking common issues:"
        
        # Check if Local by Flywheel is running
        echo "Checking if Local by Flywheel is running..."
        if [[ "$OSTYPE" == "msys" || "$OSTYPE" == "cygwin" ]]; then
            if ! tasklist | grep -i "local.exe" > /dev/null; then
                echo -e "${RED}Local by Flywheel is not running${NC}"
            fi
        else
            if ! pgrep -f "local" > /dev/null; then
                echo -e "${RED}Local by Flywheel is not running${NC}"
            fi
        fi
        
        # Check if WordPress is in debug mode
        if [[ -f "$LOCAL_PATH/../../wp-config.php" ]]; then
            echo "Checking WordPress debug settings..."
            grep "WP_DEBUG\|WP_DEBUG_LOG\|WP_DEBUG_DISPLAY" "$LOCAL_PATH/../../wp-config.php"
        fi
        
        # Check PHP error log with more context
        if [[ -f "$LOCAL_PATH/../../php_error.log" ]]; then
            echo "Recent PHP errors with context:"
            tail -n 50 "$LOCAL_PATH/../../php_error.log" | grep -B 2 -A 2 "Error\|Warning\|Notice"
        fi
        
        # Check WordPress debug log with pattern context
        if [[ -f "$LOCAL_PATH/../../wp-content/debug.log" ]]; then
            echo "Recent WordPress errors with pattern context:"
            tail -n 50 "$LOCAL_PATH/../../wp-content/debug.log" | grep -B 2 -A 2 "block_pattern\|stay_n_alive\|Fatal error"
        fi
        
        # Check theme files
        echo "Verifying critical theme files..."
        local required_files=(
            "style.css"
            "index.php"
            "functions.php"
            "theme.json"
        )
        
        for file in "${required_files[@]}"; do
            if [[ ! -f "$LOCAL_PATH/$THEME_DIR/$file" ]]; then
                echo -e "${RED}Error: Missing required theme file: $file${NC}"
            fi
        done
        
        # Check file permissions
        echo "Checking theme directory permissions..."
        if [[ "$OSTYPE" == "msys" || "$OSTYPE" == "cygwin" ]]; then
            run_powershell "
                \$path = '$LOCAL_PATH/$THEME_DIR' -replace '^/c/', 'C:/' -replace '/', '\\'
                Get-Acl \$path | Format-List
            "
        else
            ls -la "$LOCAL_PATH/$THEME_DIR"
        fi
        
        return 1
    fi
    
    echo -e "${GREEN}Site health check passed!${NC}"
    return 0
}

# Move these function definitions to the top with the other functions
verify_theme_setup() {
    echo "Verifying theme setup..."
    
    if [[ ! -f "$LOCAL_PATH/$THEME_DIR/inc/theme-setup.php" ]]; then
        log_error "theme-setup.php not found"
        return 1
    fi
    
    # Create backup
    cp "$LOCAL_PATH/$THEME_DIR/inc/theme-setup.php" "$LOCAL_PATH/$THEME_DIR/inc/theme-setup.php.bak" || {
        log_error "Failed to create backup of theme-setup.php"
        return 1
    }
    
    # Update theme setup
    cat > "$LOCAL_PATH/$THEME_DIR/inc/theme-setup.php" << 'EOL'
<?php
/**
 * Theme Setup
 *
 * @package Stay_N_Alive
 */

if ( ! defined( 'ABSPATH' ) ) {
    exit; // Exit if accessed directly
}

if ( ! function_exists( 'stay_n_alive_theme_setup' ) ) {
    function stay_n_alive_theme_setup() {
        add_theme_support( 'automatic-feed-links' );
        add_theme_support( 'title-tag' );
        add_theme_support( 'post-thumbnails' );
        add_theme_support( 'align-wide' );
        add_theme_support( 'responsive-embeds' );
        add_theme_support( 'custom-line-height' );
        add_theme_support( 'experimental-link-color' );
        add_theme_support( 'custom-spacing' );
        add_theme_support( 'wp-block-styles' );
        add_theme_support( 'editor-styles' );
        add_editor_style( 'assets/css/editor-style.css' );
    }
}

add_action( 'after_setup_theme', 'stay_n_alive_theme_setup' );
EOL
    
    return 0
}

verify_template_loader() {
    echo "Verifying template loader..."
    
    if [[ ! -f "$LOCAL_PATH/$THEME_DIR/inc/template-loader.php" ]]; then
        log_error "template-loader.php not found"
        return 1
    fi
    
    # Create backup
    cp "$LOCAL_PATH/$THEME_DIR/inc/template-loader.php" "$LOCAL_PATH/$THEME_DIR/inc/template-loader.php.bak" || {
        log_error "Failed to create backup of template-loader.php"
        return 1
    }
    
    # Update template loader with proper function registration
    cat > "$LOCAL_PATH/$THEME_DIR/inc/template-loader.php" << 'EOL'
<?php
/**
 * Template Loader
 *
 * @package Stay_N_Alive
 */

if ( ! defined( 'ABSPATH' ) ) {
    exit; // Exit if accessed directly
}

/**
 * Custom template loader function
 */
function stay_n_alive_template_loader( $template ) {
    // Check if we're inside a theme
    if ( ! defined( 'STAY_N_ALIVE_DIR' ) ) {
        return $template;
    }

    // Get the template slug
    $template_slug = basename( $template );
    
    // Check for custom templates
    if ( is_singular() ) {
        $custom_template = STAY_N_ALIVE_DIR . '/templates/single.html';
        if ( file_exists( $custom_template ) ) {
            return $custom_template;
        }
    }
    
    return $template;
}
add_filter( 'template_include', 'stay_n_alive_template_loader', 99 );
EOL

    # Verify the file was created
    if [[ ! -f "$LOCAL_PATH/$THEME_DIR/inc/template-loader.php" ]]; then
        log_error "Failed to create template-loader.php"
        return 1
    fi
    
    return 0
}

verify_block_patterns() {
    echo "Verifying block patterns..."
    
    if [[ ! -f "$LOCAL_PATH/$THEME_DIR/inc/block-patterns.php" ]]; then
        log_error "block-patterns.php not found"
        return 1
    fi
    
    # Create backup
    cp "$LOCAL_PATH/$THEME_DIR/inc/block-patterns.php" "$LOCAL_PATH/$THEME_DIR/inc/block-patterns.php.bak" || {
        log_error "Failed to create backup of block-patterns.php"
        return 1
    }
    
    # Update block patterns with proper function registration
    cat > "$LOCAL_PATH/$THEME_DIR/inc/block-patterns.php" << 'EOL'
<?php
/**
 * Block Patterns
 *
 * @package Stay_N_Alive
 */

if ( ! defined( 'ABSPATH' ) ) {
    exit; // Exit if accessed directly
}

/**
 * Register block patterns and categories.
 */
function stay_n_alive_register_block_patterns() {
    // Only register patterns if the function exists
    if ( ! function_exists( 'register_block_pattern' ) ) {
        return;
    }

    // Register pattern categories
    if ( function_exists( 'register_block_pattern_category' ) ) {
        register_block_pattern_category(
            'stay-n-alive',
            array( 'label' => esc_html__( 'Stay N Alive', 'stay-n-alive' ) )
        );
    }

    // Register patterns
    $block_patterns = array(
        'author-bio',
        'bio-link-button',
        'social-grid'
    );

    foreach ( $block_patterns as $block_pattern ) {
        $pattern_file = STAY_N_ALIVE_DIR . '/patterns/' . $block_pattern . '.html';
        if ( file_exists( $pattern_file ) ) {
            register_block_pattern(
                'stay-n-alive/' . $block_pattern,
                array(
                    'title'         => ucwords( str_replace( '-', ' ', $block_pattern ) ),
                    'content'       => file_get_contents( $pattern_file ),
                    'categories'    => array( 'stay-n-alive' ),
                )
            );
        }
    }
}
add_action( 'init', 'stay_n_alive_register_block_patterns' );
EOL

    return 0
}

# Main execution
echo "Available Local sites:"
if [[ "$OSTYPE" == "msys" || "$OSTYPE" == "cygwin" ]]; then
    ls -1 "$LOCAL_ROOT" 2>/dev/null || {
        echo -e "${RED}Error: No Local sites found in $LOCAL_ROOT${NC}"
        echo "Looking in: $LOCAL_ROOT"
        exit 1
    }
else
    ls -1 "$LOCAL_ROOT" 2>/dev/null || {
        echo -e "${RED}Error: No Local sites found in $LOCAL_ROOT${NC}"
        exit 1
    }
fi

# ... rest of site selection code ...

# Run verifications in correct order
verify_theme_files || {
    echo -e "${RED}Error: Theme file verification failed${NC}"
    exit 1
}

verify_theme_functions || {
    echo -e "${RED}Error: Theme function verification failed${NC}"
    exit 1
}

# Run WordPress theme debug checks
echo "Running WordPress theme debug checks..."
debug_wordpress_theme "$THEME_DIR"

# Run theme operations
run_theme_check
activate_theme

# Run single health check at the end
echo "Performing final health check..."
check_wordpress_health "staynalive.local"

if [[ $? -ne 0 ]]; then
    echo -e "${RED}Warning: Site health check failed. Please check the logs above for details.${NC}"
    echo "Common solutions:"
    echo "1. Check WordPress debug.log for PHP errors"
    echo "2. Verify theme files are properly extracted"
    echo "3. Check file permissions"
    echo "4. Verify Local by Flywheel is running"
    echo "5. Check site URL configuration"
    echo "6. Clear WordPress cache if using a caching plugin"
else
    echo -e "${GREEN}Theme deployed successfully!${NC}"
fi

# Modify the main execution order
verify_functions_php || {
    echo -e "${RED}Error: Functions.php verification failed${NC}"
    exit 1
}

verify_theme_setup || {
    echo -e "${RED}Error: Theme setup verification failed${NC}"
    exit 1
}

verify_template_loader || {
    echo -e "${RED}Error: Template loader verification failed${NC}"
    exit 1
}

verify_block_patterns || {
    echo -e "${RED}Error: Block patterns verification failed${NC}"
    exit 1
}

# Main execution should be at the bottom
main() {
    # Move all execution code here
    echo "Available Local sites:"
    # ... rest of execution code ...
    
    verify_block_patterns || {
        echo -e "${RED}Error: Block patterns verification failed${NC}"
        exit 1
    }
}

# Call main at the very end of the script
main