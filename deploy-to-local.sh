#!/usr/bin/env bash
set -euo pipefail

echo "DEBUG: Starting deploy-to-local.sh"
echo "DEBUG: Checking for existing color variables..."
echo "DEBUG: GREEN=${GREEN:-undefined}"
echo "DEBUG: BLUE=${BLUE:-undefined}"

# Source shared functions
echo "DEBUG: About to source shared-functions.sh"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/lib/shared-functions.sh"
echo "DEBUG: Finished sourcing shared-functions.sh"

# Constants
echo "DEBUG: Defining local constants..."

# OS-specific paths
if [[ "$OSTYPE" == "msys" || "$OSTYPE" == "cygwin" ]]; then
    readonly LOCAL_ROOT="/c/Users/$USERNAME/Local Sites"
else
    readonly LOCAL_ROOT="$HOME/Local Sites"
fi

readonly THEME_DIR="staynalive"
readonly THEME_ZIP="staynalive.zip"

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
        "assets/css/blocks/custom-styles.css"
    )
    
    echo "Verifying theme file structure..."
    
    for file in "${required_files[@]}"; do
        if [[ ! -f "$local_path/$THEME_DIR/$file" ]]; then
            log_error "Missing required theme file: $file"
            return 1
        fi
    done
    
    # Run PHPCS on PHP files if available
    if command -v phpcs >/dev/null 2>&1; then
        echo "Running PHPCS validation..."
        echo "DEBUG: Checking PHPCS configuration..."
        export XDEBUG_MODE=off
        
        # Initialize composer if needed
        if [[ ! -f "composer.json" ]]; then
            echo "DEBUG: Initializing composer..."
            composer init --quiet --no-interaction
        fi
        
        # Install WordPress Coding Standards
        echo "DEBUG: Installing WordPress Coding Standards..."
        if ! composer require --dev \
            dealerdirect/phpcodesniffer-composer-installer \
            wp-coding-standards/wpcs \
            phpcompatibility/php-compatibility \
            phpcsstandards/phpcsutils \
            phpcsstandards/phpcsextra; then
            echo "WARNING: Could not install PHPCS dependencies"
            return 0
        fi
        
        # Configure PHPCS
        echo "DEBUG: Configuring PHPCS..."
        vendor/bin/phpcs --config-set installed_paths \
            vendor/wp-coding-standards/wpcs,\
            vendor/phpcompatibility/php-compatibility,\
            vendor/phpcsstandards/phpcsutils,\
            vendor/phpcsstandards/phpcsextra
        
        # Verify PHPCS configuration
        echo "DEBUG: Installed coding standards:"
        vendor/bin/phpcs -i
        
        for file in functions.php inc/*.php; do
            if [[ -f "$local_path/$THEME_DIR/$file" ]]; then
                echo "DEBUG: Running PHPCS on $file..."
                # Try to fix the file first
                echo "DEBUG: Attempting to fix coding standards in $file..."
                if ! vendor/bin/phpcbf --standard=WordPress "$local_path/$THEME_DIR/$file" >/dev/null 2>&1; then
                    echo "WARNING: Could not automatically fix all issues in $file"
                fi
                
                # Run validation after fixes
                if ! vendor/bin/phpcs \
                    --standard=WordPress-Core \
                    --runtime-set installed_paths vendor/wp-coding-standards/wpcs \
                    --ignore=*/vendor/*,*/node_modules/* \
                    --extensions=php \
                    "$local_path/$THEME_DIR/$file" >/dev/null 2>&1; then
                    echo "WARNING: Some issues remain in $file after fixes (non-critical)"
                    echo "DEBUG: Remaining issues:"
                    vendor/bin/phpcs \
                        --standard=WordPress-Core \
                        --runtime-set installed_paths vendor/wp-coding-standards/wpcs \
                        --ignore=*/vendor/*,*/node_modules/* \
                        --extensions=php \
                        "$local_path/$THEME_DIR/$file"
                fi
            fi
        done
    fi
    
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

define( 'STAYNALIVE_VERSION', '1.0.0' );
define( 'STAYNALIVE_DIR', get_template_directory() );
define( 'STAYNALIVE_URI', get_template_directory_uri() );

require_once STAYNALIVE_DIR . '/inc/theme-setup.php';
require_once STAYNALIVE_DIR . '/inc/template-loader.php';
require_once STAYNALIVE_DIR . '/inc/block-patterns.php';
require_once STAYNALIVE_DIR . '/inc/security.php';
require_once STAYNALIVE_DIR . '/inc/performance.php';
require_once STAYNALIVE_DIR . '/inc/social-feeds.php';
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

function staynalive_theme_setup() {
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
add_action( 'after_setup_theme', 'staynalive_theme_setup' );
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

function staynalive_template_loader( $template ) {
    // Check for front page first
    if ( is_front_page() ) {
        $front_template = get_theme_file_path( '/templates/front-page.html' );
        if ( file_exists( $front_template ) ) {
            return $front_template;
        }
    }
    
    if ( is_singular() ) {
        $custom_template = get_theme_file_path( '/templates/single.html' );
        if ( file_exists( $custom_template ) ) {
            return $custom_template;
        }
    }
    return $template;
}
add_filter( 'template_include', 'staynalive_template_loader', 99 );
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
    
    # Try HTTPS first, fallback to HTTP
    local protocols=("https" "http")
    local success=0
    
    for protocol in "${protocols[@]}"; do
        if curl -sSf --max-time 10 "${protocol}://${site_url}" > /dev/null 2>&1; then
            success=1
            break
        fi
    done
    
    if [[ $success -eq 0 ]]; then
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
    
    # Verify REST API is accessible
    if ! curl -sSf --max-time 10 "http://${site_url}/wp-json" > /dev/null 2>&1; then
        log_error "WordPress REST API is not accessible"
        return 1
    fi
    
    # Verify block editor is active
    if ! curl -sSf --max-time 10 "http://${site_url}/wp-json/wp/v2/block-types" > /dev/null 2>&1; then
        log_error "Block editor API not accessible - Gutenberg may be disabled"
        return 1
    fi
    
    # Then verify theme activation
    if ! curl -sSf --max-time 10 "http://${site_url}/wp-json/wp/v2/themes" | grep -q "\"stylesheet\":\"staynalive\""; then
        log_error "Theme is not active"
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
    
    # Create patterns directory if needed
    if ! mkdir -p "$local_path/$THEME_DIR/patterns"; then
        log_error "Failed to create patterns directory"
        return 1
    fi
    
    # Create author bio pattern
    if ! cat > "$local_path/$THEME_DIR/patterns/author-bio.html" << 'EOL'
<!-- wp:pattern {"slug":"staynalive/author-bio","title":"Author Bio"} -->
<!-- wp:group {"className":"author-bio","layout":{"type":"constrained"}} -->
<div class="wp-block-group author-bio">
    <!-- wp:columns {"verticalAlignment":"center"} -->
    <div class="wp-block-columns are-vertically-aligned-center">
        <!-- wp:column {"width":"25%"} -->
        <div class="wp-block-column" style="flex-basis:25%">
            <!-- wp:image {"className":"is-style-rounded"} -->
            <figure class="wp-block-image is-style-rounded">
                <img src="[author_avatar_url]" alt="Author avatar"/>
            </figure>
            <!-- /wp:image -->
        </div>
        <!-- /wp:column -->

        <!-- wp:column {"width":"75%"} -->
        <div class="wp-block-column" style="flex-basis:75%">
            <!-- wp:heading {"level":3} -->
            <h3>[author_name]</h3>
            <!-- /wp:heading -->

            <!-- wp:paragraph -->
            <p>[author_bio]</p>
            <!-- /wp:paragraph -->

            <!-- wp:social-links -->
            <ul class="wp-block-social-links">
                <!-- wp:social-link {"url":"#","service":"twitter"} /-->
                <!-- wp:social-link {"url":"#","service":"linkedin"} /-->
            </ul>
            <!-- /wp:social-links -->
        </div>
        <!-- /wp:column -->
    </div>
    <!-- /wp:columns -->
</div>
<!-- /wp:group -->
<!-- /wp:pattern -->
EOL
    then
        log_error "Failed to write author-bio.html"
        return 1
    fi
    
    # Update block patterns registration
    if ! cat > "$local_path/$THEME_DIR/inc/block-patterns.php" << 'EOL'
<?php
/**
 * Block Patterns
 *
 * @package Staynalive
 */

if ( ! defined( 'ABSPATH' ) ) {
    exit;
}

/**
 * Register Block Patterns
 */
function staynalive_register_block_patterns() {
    if ( ! function_exists( 'register_block_pattern_category' ) ) {
        return;
    }

    // Register pattern category
    register_block_pattern_category(
        'staynalive',
        array(
            'label' => __( 'Stay N Alive', 'staynalive' ),
        )
    );

    // Register patterns
    $block_patterns = array(
        'author-bio',
        'bio-link-button',
        'cta',
        'featured-post',
        'social-grid'
    );

    foreach ( $block_patterns as $block_pattern ) {
        $pattern_file = get_theme_file_path( "/patterns/{$block_pattern}.html" );
        
        if ( ! file_exists( $pattern_file ) ) {
            continue;
        }

        register_block_pattern(
            'staynalive/' . $block_pattern,
            array(
                'title'         => ucwords( str_replace( '-', ' ', $block_pattern ) ),
                'categories'    => array( 'staynalive' ),
                'content'       => file_get_contents( $pattern_file ),
            )
        );
    }
}
add_action( 'init', 'staynalive_register_block_patterns' );
EOL
    then
        log_error "Failed to write block-patterns.php"
        return 1
    fi

    return 0
}

verify_html_syntax() {
    echo "DEBUG: Starting HTML syntax verification..."
    
    local template_files=(
        "templates/404.html"
        "templates/archive.html"
        "templates/author.html"
        "templates/category.html"
        "templates/front-page.html"
        "templates/index.html"
        "templates/link-bio.html"
        "templates/search.html"
        "templates/single.html"
        "templates/tag.html"
    )
    
    local pattern_files=(
        "patterns/author-bio.html"
        "patterns/bio-link-button.html"
        "patterns/cta.html"
        "patterns/featured-post.html"
        "patterns/social-grid.html"
    )
    
    local part_files=(
        "parts/header.html"
        "parts/footer.html"
    )
    
    local templates_count=0
    local parts_count=0
    local patterns_count=0
    
    # Verify files exist and have content
    for file in "${template_files[@]}" "${pattern_files[@]}" "${part_files[@]}"; do
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
            "templates/"*)
                # All templates must have proper block structure
                if ! grep -q "<!-- wp:template-part.*\"slug\":\"header\"" "$local_path/$THEME_DIR/$file" || \
                   ! grep -q "<!-- wp:template-part.*\"slug\":\"footer\"" "$local_path/$THEME_DIR/$file" || \
                   ! grep -q "<!-- wp:group.*\"tagName\":\"main\"" "$local_path/$THEME_DIR/$file"; then
                    echo "DEBUG: Checking template structure..."
                    echo "Header template part: $(grep -q "<!-- wp:template-part.*\"slug\":\"header\"" "$local_path/$THEME_DIR/$file" && echo "Found" || echo "Missing")"
                    echo "Footer template part: $(grep -q "<!-- wp:template-part.*\"slug\":\"footer\"" "$local_path/$THEME_DIR/$file" && echo "Found" || echo "Missing")"
                    echo "Main content group: $(grep -q "<!-- wp:group.*\"tagName\":\"main\"" "$local_path/$THEME_DIR/$file" && echo "Found" || echo "Missing")"
                    log_error "$file missing required template structure"
                    echo "Current content:"
                    cat "$local_path/$THEME_DIR/$file"
                    return 1
                fi
                
                # Check for theme.json style integration
                if ! grep -q "className=\".*wp-block-\|style=\"\|{\"style\":" "$local_path/$THEME_DIR/$file"; then
                    log_error "$file missing theme.json style integration"
                    echo "Current content:"
                    cat "$local_path/$THEME_DIR/$file"
                    return 1
                fi
                
                # Specific template checks
                case "$file" in
                    "templates/index.html")
                        if ! grep -q "wp:query" "$local_path/$THEME_DIR/$file"; then
                            log_error "index.html missing required query block"
                            echo "Current content:"
                            cat "$local_path/$THEME_DIR/$file"
                            return 1
                        fi
                        ;;
                    "templates/front-page.html")
                        # Check that both patterns exist, regardless of order
                        if ! grep -q "<!-- wp:pattern.*\"slug\":\"staynalive/featured-post\"" "$local_path/$THEME_DIR/$file" || \
                           ! grep -q "<!-- wp:pattern.*\"slug\":\"staynalive/cta\"" "$local_path/$THEME_DIR/$file"; then
                            log_error "front-page.html missing required pattern blocks"
                            echo "Current content:"
                            cat "$local_path/$THEME_DIR/$file"
                            return 1
                        fi
                        ;;
                esac
                ;;
            "patterns/"*)
                # Check for required block structure
                if ! grep -q "<!-- wp:group {\".*\"}" "$local_path/$THEME_DIR/$file" || \
                   ! grep -q "<!-- /wp:group -->" "$local_path/$THEME_DIR/$file"; then
                    log_error "$file missing required block structure"
                    echo "Current content:"
                    cat "$local_path/$THEME_DIR/$file"
                    return 1
                fi
                
                # Verify all blocks are properly closed
                local open_blocks
                local close_blocks
                open_blocks=$(grep -c "<!-- wp:" "$local_path/$THEME_DIR/$file")
                close_blocks=$(grep -c "<!-- /wp:" "$local_path/$THEME_DIR/$file")
                if [[ $open_blocks -ne $close_blocks ]]; then
                    log_error "$file has mismatched block tags: $open_blocks opens vs $close_blocks closes"
                    echo "Current content:"
                    cat "$local_path/$THEME_DIR/$file"
                    return 1
                fi
                ;;
        esac
        
        # Count file types
        if [[ "$file" =~ ^templates/ ]]; then
            ((templates_count++))
        fi
        if [[ "$file" =~ ^parts/ ]]; then
            ((parts_count++))
        fi
        if [[ "$file" =~ ^patterns/ ]]; then
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
    echo "=== front-page.html ==="
    cat "$local_path/$THEME_DIR/templates/front-page.html"
    echo
    echo "=== index.html ==="
    cat "$local_path/$THEME_DIR/templates/index.html"
    
    echo "DEBUG: HTML syntax verification complete"
    return 0
}

# Clean up checkpoint files before creating zip
cleanup_checkpoints() {
    echo "Cleaning up checkpoint files..."
    # Remove from source directory
    find "${THEME_DIR}" -name ".checkpoint_*" -type f -exec rm -f {} \;
    # Also clean from zip if it exists
    if [[ -f "${THEME_ZIP}" ]]; then
        local temp_dir
        temp_dir=$(mktemp -d)
        unzip -q "${THEME_ZIP}" -d "${temp_dir}"
        find "${temp_dir}" -name ".checkpoint_*" -type f -exec rm -f {} \;
        (cd "${temp_dir}" && zip -r "${THEME_ZIP}" .)
    fi
    return 0
}

# Fix path truncation in debug output
debug_powershell_paths() {
    echo "DEBUG: PowerShell - Destination path:"
    echo "$1" | fold -w 100
    local win_path
    win_path=$(echo "$1" | sed 's|^/\([a-z]\)/|\1:/|' | tr '/' '\\')
    echo "DEBUG: PowerShell - Converted destination path:"
    echo "$win_path" | fold -w 100
}

# Cleanup function
cleanup_on_exit() {
    local exit_code=$?
    if [[ $exit_code -ne 0 ]]; then
        echo "Script failed with exit code $exit_code"
        # Clean up temporary files
        find . -name "*.bak" -type f -delete
        find . -name ".checkpoint_*" -type f -delete
    fi
    exit $exit_code
}

# Set trap
trap cleanup_on_exit EXIT

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
    
    # Check if we need to create the zip file
    if [[ ! -f "$THEME_ZIP" ]]; then
        echo "Creating theme zip file..."
        if ! zip -r "$THEME_ZIP" "$THEME_DIR"; then
            log_error "Failed to create theme zip file"
            exit 1
        fi
    fi
    
    echo "DEBUG: Theme zip exists: $([[ -f "$THEME_ZIP" ]] && echo "Yes" || echo "No")"
    echo "DEBUG: Theme zip size: $(stat -f%z "$THEME_ZIP" 2>/dev/null || stat -c%s "$THEME_ZIP" 2>/dev/null || echo "unknown")"
    
    # Clean up checkpoints before adding to zip
    cleanup_checkpoints || {
        log_error "Failed to clean up checkpoints"
        exit 1
    }
    
    # Recreate zip without checkpoints
    echo "DEBUG: Recreating zip file..."
    if command -v zip >/dev/null 2>&1; then
        echo "DEBUG: Using zip command..."
        # Convert backslashes to forward slashes for zip
        if [[ "$OSTYPE" == "msys" || "$OSTYPE" == "cygwin" ]]; then
            find "$THEME_DIR" -type f -exec sh -c 'echo "{}" | sed "s/\\\\/\\//g"' \; | zip -@ "$THEME_ZIP"
        else
            if ! zip -r "$THEME_ZIP" "$THEME_DIR"; then
                log_error "Failed to recreate theme zip file with zip command"
                exit 1
            fi
        fi
    elif [[ "$OSTYPE" == "msys" || "$OSTYPE" == "cygwin" ]]; then
        echo "DEBUG: zip not found, using PowerShell Compress-Archive..."
        # Convert paths to Windows format
        local win_source="${THEME_DIR//\//\\}"
        local win_dest="${THEME_ZIP//\//\\}"
        
        if ! powershell.exe -Command "
            \$ErrorActionPreference = 'Stop'
            Write-Host 'DEBUG: Starting compression...'
            if (Test-Path '$win_dest') {
                Remove-Item -Path '$win_dest' -Force
            }
            Compress-Archive -Path '$win_source\\*' -DestinationPath '$win_dest' -Force
            Write-Host 'DEBUG: Compression completed'
            \$true
        "; then
            log_error "Failed to create zip file using PowerShell"
            exit 1
        fi
    else
        log_error "No zip command found and not on Windows - cannot create zip file"
        exit 1
    fi
    
    # Use PowerShell for extraction on Windows
    if [[ "$OSTYPE" == "msys" || "$OSTYPE" == "cygwin" ]]; then
        echo "DEBUG: Using PowerShell to extract zip"
        debug_powershell_paths "$local_path/$THEME_DIR"
        if ! run_powershell "
            \$destPath = '$local_path/$THEME_DIR' -replace '^/c/', 'C:/' -replace '/', '\\'
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
    
    # Use shared functions for verification
    verify_theme_files || exit 1
    verify_theme_functions || exit 1
    verify_functions_php || exit 1
    verify_theme_setup || exit 1
    verify_template_loader || exit 1
    verify_block_patterns || exit 1
    verify_html_syntax || exit 1
    
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