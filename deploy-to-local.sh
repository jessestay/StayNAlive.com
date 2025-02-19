#!/usr/bin/env bash
set -euo pipefail

# Constants
readonly GREEN='\033[0;32m'
readonly RED='\033[0;31m'
readonly YELLOW='\033[0;33m'
readonly NC='\033[0m'

# OS-specific paths
if [[ "$OSTYPE" == "msys" || "$OSTYPE" == "cygwin" ]]; then
    readonly LOCAL_ROOT="/c/Users/$USERNAME/Local Sites"
else
    readonly LOCAL_ROOT="$HOME/Local Sites"
fi

readonly THEME_DIR="stay-n-alive"
readonly THEME_ZIP="stay-n-alive.zip"

# Function definitions
log_error() {
    local message="$1"
    local file="${2:-}"  # Default to empty string if not provided
    local function_name="${FUNCNAME[1]}"
    local timestamp
    timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    
    echo -e "${RED}[$timestamp] ERROR in $function_name: $message${NC}"
    
    if [[ -n "$file" ]] && [[ -f "$file" ]]; then
        echo "File contents at time of error:"
        head -n 20 "$file"
        echo "..."
        tail -n 20 "$file"
    fi
}

run_powershell() {
    local command="$1"
    local error_msg="${2:-PowerShell command failed}"
    
    if ! command -v powershell.exe >/dev/null 2>&1; then
        log_error "PowerShell is not available"
        return 1
    fi
    
    if ! powershell.exe -Command "
        \$ErrorActionPreference = 'Stop'
        try {
            $command
        }
        catch {
            Write-Host \"ERROR: \$_\"
            exit 1
        }
    "; then
        log_error "$error_msg"
        return 1
    fi
}

backup_theme() {
    local theme_dir="$1"
    local local_path="$2"
    local backup_name
    
    backup_name="${theme_dir}_backup_$(date +%Y%m%d_%H%M%S)"
    
    if [[ ! -d "$local_path/$theme_dir" ]]; then
        return 0
    fi
    
    echo "Creating backup of existing theme..."
    if ! mv "$local_path/$theme_dir" "$local_path/$backup_name"; then
        log_error "Could not create backup"
        return 1
    fi
    
    echo "Backup created at: $backup_name"
    return 0
}

verify_theme_files() {
    echo "DEBUG: Starting theme file verification..."
    
    # Check file permissions
    echo "Checking file permissions..."
    if [[ "$OSTYPE" != "msys" && "$OSTYPE" != "cygwin" ]]; then
        find "$local_path/$THEME_DIR" -type f -exec chmod 644 {} \;
        find "$local_path/$THEME_DIR" -type d -exec chmod 755 {} \;
    fi
    
    local required_files=(
        "style.css"
        "index.php"
        "functions.php"
        "theme.json"
        "inc/block-patterns.php"
        "inc/theme-setup.php"
    )
    
    echo "Verifying theme file structure..."
    
    for file in "${required_files[@]}"; do
        if [[ ! -f "$local_path/$THEME_DIR/$file" ]]; then
            log_error "Missing required theme file: $file"
            return 1
        fi
    done
    
    echo "DEBUG: Theme file verification complete"
    return 0
}

verify_theme_functions() {
    echo "Verifying theme function definitions..."
    
    # Create inc directory if needed
    if ! mkdir -p "$local_path/$THEME_DIR/inc"; then
        log_error "Failed to create inc directory"
        return 1
    fi
    
    echo "DEBUG: Theme function verification complete"
    return 0
}

verify_functions_php() {
    echo "Verifying functions.php..."
    
    if [[ ! -f "$local_path/$THEME_DIR/functions.php" ]]; then
        log_error "functions.php not found"
        return 1
    fi
    
    # Create backup
    if ! cp "$local_path/$THEME_DIR/functions.php" "$local_path/$THEME_DIR/functions.php.bak"; then
        log_error "Failed to create backup of functions.php"
        return 1
    fi
    
    cat > "$local_path/$THEME_DIR/functions.php" << 'EOL'
<?php
if ( ! defined( 'ABSPATH' ) ) {
    exit;
}

define( 'STAY_N_ALIVE_VERSION', '1.0.0' );
define( 'STAY_N_ALIVE_DIR', get_template_directory() );
define( 'STAY_N_ALIVE_URI', get_template_directory_uri() );

require_once STAY_N_ALIVE_DIR . '/inc/theme-setup.php';
require_once STAY_N_ALIVE_DIR . '/inc/template-loader.php';
require_once STAY_N_ALIVE_DIR . '/inc/block-patterns.php';
require_once STAY_N_ALIVE_DIR . '/inc/security.php';
require_once STAY_N_ALIVE_DIR . '/inc/performance.php';
require_once STAY_N_ALIVE_DIR . '/inc/social-feeds.php';
EOL

    return 0
}

verify_theme_setup() {
    echo "Verifying theme setup..."
    
    if [[ ! -f "$local_path/$THEME_DIR/inc/theme-setup.php" ]]; then
        log_error "theme-setup.php not found"
        return 1
    fi
    
    if ! cat > "$local_path/$THEME_DIR/inc/theme-setup.php" << 'EOL'
<?php
if ( ! defined( 'ABSPATH' ) ) {
    exit;
}

function stay_n_alive_theme_setup() {
    add_theme_support( 'automatic-feed-links' );
    add_theme_support( 'title-tag' );
    add_theme_support( 'post-thumbnails' );
    add_theme_support( 'align-wide' );
    add_theme_support( 'responsive-embeds' );
    add_theme_support( 'custom-line-height' );
    add_theme_support( 'custom-spacing' );
    add_theme_support( 'wp-block-styles' );
    add_theme_support( 'editor-styles' );
    add_editor_style( 'assets/css/editor-style.css' );
}
add_action( 'after_setup_theme', 'stay_n_alive_theme_setup' );
EOL
    then
        log_error "Failed to write theme-setup.php"
        return 1
    fi

    return 0
}

verify_template_loader() {
    echo "Verifying template loader..."
    
    if [[ ! -f "$local_path/$THEME_DIR/inc/template-loader.php" ]]; then
        log_error "template-loader.php not found"
        return 1
    fi
    
    if ! cat > "$local_path/$THEME_DIR/inc/template-loader.php" << 'EOL'
<?php
if ( ! defined( 'ABSPATH' ) ) {
    exit;
}

function stay_n_alive_template_loader( $template ) {
    if ( is_singular() ) {
        $custom_template = get_theme_file_path( '/templates/single.html' );
        if ( file_exists( $custom_template ) ) {
            return $custom_template;
        }
    }
    return $template;
}
add_filter( 'template_include', 'stay_n_alive_template_loader', 99 );
EOL
    then
        log_error "Failed to write template-loader.php"
        return 1
    fi

    return 0
}

check_wordpress_health() {
    local site_url="$1"
    echo "Checking WordPress site health..."
    
    if ! curl -sSf --max-time 10 "http://${site_url}" > /dev/null 2>&1; then
        local curl_exit=$?
        log_error "Cannot access homepage at http://${site_url}"
        
        case $curl_exit in
            6)  echo "Could not resolve host: DNS lookup failed" ;;
            7)  echo "Failed to connect: Local by Flywheel might not be running" ;;
            28) echo "Connection timed out after 10 seconds" ;;
            *)  echo "Curl error code: $curl_exit" ;;
        esac
        
        if [[ "$OSTYPE" == "msys" || "$OSTYPE" == "cygwin" ]]; then
            if ! tasklist | grep -i "local.exe" > /dev/null; then
                log_error "Local by Flywheel is not running"
            fi
        else
            if ! pgrep -f "local" > /dev/null; then
                log_error "Local by Flywheel is not running"
            fi
        fi
        
        return 1
    fi
    
    return 0
}

verify_block_patterns() {
    echo "Verifying block patterns..."
    
    if [[ ! -f "$local_path/$THEME_DIR/inc/block-patterns.php" ]]; then
        log_error "block-patterns.php not found"
        return 1
    fi
    
    # Create backup
    if ! cp "$local_path/$THEME_DIR/inc/block-patterns.php" "$local_path/$THEME_DIR/inc/block-patterns.php.bak"; then
        log_error "Failed to create backup of block-patterns.php"
        return 1
    fi
    
    # Update block patterns with proper function registration
    if ! cat > "$local_path/$THEME_DIR/inc/block-patterns.php" << 'EOL'
<?php
/**
 * Block Patterns
 *
 * @package Stay_N_Alive
 */

if ( ! defined( 'ABSPATH' ) ) {
    exit;
}

function stay_n_alive_register_block_patterns() {
    if ( ! function_exists( 'register_block_pattern' ) ) {
        return;
    }

    register_block_pattern_category(
        'stay-n-alive',
        array( 'label' => esc_html__( 'Stay N Alive', 'stay-n-alive' ) )
    );

    $patterns = array(
        'author-bio',
        'bio-link-button',
        'social-grid'
    );

    foreach ( $patterns as $pattern ) {
        $pattern_file = get_theme_file_path( "/patterns/{$pattern}.html" );
        if ( file_exists( $pattern_file ) ) {
            register_block_pattern(
                'stay-n-alive/' . $pattern,
                array(
                    'title' => ucwords( str_replace( '-', ' ', $pattern ) ),
                    'content' => file_get_contents( $pattern_file ),
                    'categories' => array( 'stay-n-alive' )
                )
            );
        }
    }
}
add_action( 'init', 'stay_n_alive_register_block_patterns' );
EOL
    then
        log_error "Failed to write block-patterns.php"
        return 1
    fi

    return 0
}

verify_html_syntax() {
    echo "DEBUG: Starting HTML syntax verification..."
    
    local templates_count=0
    local parts_count=0
    local patterns_count=0
    
    # Define HTML files to validate
    local html_files=(
        "templates/404.html"
        "templates/archive.html"
        "templates/author.html"
        "templates/category.html"
        "templates/index.html"
        "templates/link-bio.html"
        "templates/search.html"
        "templates/single.html"
        "templates/tag.html"
        "parts/footer.html"
        "parts/header.html"
        "patterns/author-bio.html"
        "patterns/bio-link-button.html"
        "patterns/social-grid.html"
    )
    
    # Verify files exist and have content
    for file in "${html_files[@]}"; do
        echo "DEBUG: Checking $file..."
        if [[ ! -f "$local_path/$THEME_DIR/$file" ]]; then
            log_error "Missing required file: $file"
            return 1
        fi
        
        if [[ ! -s "$local_path/$THEME_DIR/$file" ]]; then
            log_error "Empty file: $file"
            return 1
        fi
        
        # Fail fast if PHP found in any HTML file
        if grep -q "<?php" "$local_path/$THEME_DIR/$file"; then
            log_error "$file contains PHP code - should be pure block markup"
            echo "Current content:"
            cat "$local_path/$THEME_DIR/$file"
            return 1
        fi
        
        # Validate specific template content
        case "$file" in
            "templates/index.html")
                if ! grep -q "wp:query" "$local_path/$THEME_DIR/$file"; then
                    log_error "index.html missing required query block"
                    echo "Current content:"
                    cat "$local_path/$THEME_DIR/$file"
                    return 1
                fi
                ;;
            "parts/header.html")
                if grep -q "<?php" "$local_path/$THEME_DIR/$file"; then
                    log_error "header.html contains PHP code - should be pure block markup"
                    echo "Current content:"
                    cat "$local_path/$THEME_DIR/$file"
                    return 1
                fi
                ;;
            "parts/footer.html")
                if grep -q "<?php" "$local_path/$THEME_DIR/$file"; then
                    log_error "footer.html contains PHP code - should be pure block markup"
                    echo "Current content:"
                    cat "$local_path/$THEME_DIR/$file"
                    return 1
                fi
                ;;
        esac
        
        # Count file types
        if [[ "$file" =~ ^templates/ ]]; then
            ((templates_count++))
        elif [[ "$file" =~ ^parts/ ]]; then
            ((parts_count++))
        elif [[ "$file" =~ ^patterns/ ]]; then
            ((patterns_count++))
        fi
    done
    
    echo "HTML Validation Summary:"
    echo "Templates verified: $templates_count"
    echo "Template parts verified: $parts_count"
    echo "Block patterns verified: $patterns_count"
    echo "Total files checked: $((templates_count + parts_count + patterns_count))"
    
    # Show content of critical files
    echo
    echo "Critical file contents:"
    echo "=== index.html ==="
    cat "$local_path/$THEME_DIR/templates/index.html"
    echo
    echo "=== header.html ==="
    cat "$local_path/$THEME_DIR/parts/header.html"
    echo
    echo "=== footer.html ==="
    cat "$local_path/$THEME_DIR/parts/footer.html"
    
    echo "DEBUG: HTML syntax verification complete"
    return 0
}

main() {
    local site_name
    local local_path
    local choice
    local curl_exit
    
    # Get available sites
    echo "Available Local sites:"
    if ! ls -1 "$LOCAL_ROOT" 2>/dev/null; then
        log_error "No Local sites found in $LOCAL_ROOT"
        exit 1
    fi
    
    # Get site selection
    read -rp "Enter Local site name [staynalive]: " site_name
    site_name=${site_name:-staynalive}
    
    # Set paths
    local_path="$LOCAL_ROOT/$site_name/app/public/wp-content/themes"
    
    # Verify site exists
    if [[ ! -d "$local_path" ]]; then
        log_error "Local site not found at $local_path"
        exit 1
    fi
    
    # Confirm deployment
    read -rp "Continue? [Y/n] " -n 1 -r REPLY
    echo
    REPLY=${REPLY:-Y}
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        echo "Deployment cancelled"
        exit 1
    fi
    
    # Handle existing theme
    if [[ -d "$local_path/$THEME_DIR" ]]; then
        echo -e "${YELLOW}Theme directory already exists${NC}"
        read -rp "Do you want to (O)verwrite, (B)ackup and overwrite, or (C)ancel? [O/b/c]: " choice
        choice=${choice:-O}
        case "${choice^^}" in
            O*) rm -rf "$local_path/$THEME_DIR" ;;
            B*) backup_theme "$THEME_DIR" "$local_path" || exit 1 ;;
            *) echo "Deployment cancelled"; exit 0 ;;
        esac
    fi
    
    # Create theme directory
    if ! mkdir -p "$local_path/$THEME_DIR"; then
        log_error "Could not create theme directory"
        exit 1
    fi
    
    # Deploy theme
    echo "Deploying theme to Local..."
    echo "DEBUG: Current directory: $(pwd)"
    echo "DEBUG: Theme zip exists: $([[ -f "$THEME_ZIP" ]] && echo "Yes" || echo "No")"
    echo "DEBUG: Theme zip size: $(stat -f%z "$THEME_ZIP" 2>/dev/null || stat -c%s "$THEME_ZIP" 2>/dev/null || echo "unknown")"
    
    # Add zip check before extraction
    if [[ ! -f "$THEME_ZIP" ]]; then
        log_error "Theme zip file not found: $THEME_ZIP"
        exit 1
    fi
    
    # Use PowerShell for extraction on Windows
    if [[ "$OSTYPE" == "msys" || "$OSTYPE" == "cygwin" ]]; then
        echo "DEBUG: Using PowerShell to extract zip"
        if ! run_powershell "
            Write-Host \"DEBUG: PowerShell - Zip file path: $THEME_ZIP\"
            Write-Host \"DEBUG: PowerShell - Destination path: $local_path/$THEME_DIR\"
            \$destPath = '$local_path/$THEME_DIR' -replace '^/c/', 'C:/' -replace '/', '\\'
            Write-Host \"DEBUG: PowerShell - Converted destination path: \$destPath\"
            Expand-Archive -Path '$THEME_ZIP' -DestinationPath \$destPath -Force
            Write-Host \"DEBUG: PowerShell - Extraction complete\"
            Get-ChildItem -Path \$destPath -Recurse | Select-Object FullName
        "; then
            log_error "Could not extract theme to Local"
            exit 1
        fi
    else
        if ! unzip -o "$THEME_ZIP" -d "$local_path/$THEME_DIR"; then
            log_error "Could not extract theme to Local"
            exit 1
        fi
    fi
    
    # Clean up old checkpoints
    echo "Cleaning up old checkpoints..."
    local old_checkpoints
    old_checkpoints=$(find "$local_path/$THEME_DIR" -name ".checkpoint_*" -type f -mtime +1)
    if [[ -n "$old_checkpoints" ]]; then
        echo "Found old checkpoints to clean:"
        echo "$old_checkpoints"
        local checkpoint_count
        checkpoint_count=$(echo "$old_checkpoints" | wc -l)
        find "$local_path/$THEME_DIR" -name ".checkpoint_*" -type f -mtime +1 -delete
        echo "Cleaned $checkpoint_count old checkpoint files"
    else
        echo "No old checkpoints found"
    fi
    
    # Now run verifications
    verify_theme_files || exit 1
    verify_theme_functions || exit 1
    verify_functions_php || exit 1
    verify_theme_setup || exit 1
    verify_template_loader || exit 1
    verify_block_patterns || exit 1
    verify_html_syntax || exit 1
    
    # Final health check
    check_wordpress_health "staynalive.local"
    
    if [[ $? -ne 0 ]]; then
        echo -e "${RED}Warning: Site health check failed${NC}"
        echo "Check logs above for details"
    else
        echo -e "${GREEN}Theme deployed successfully!${NC}"
    fi
}

# Execute main
main