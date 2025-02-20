#!/usr/bin/env bash

# Source shared functions
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/lib/shared-functions.sh"

# Theme directory name
readonly THEME_DIR="staynalive"
readonly THEME_ZIP="staynalive.zip"

# Set each option individually
set -e
set -u
shopt -s -o pipefail

# Main execution function
main() {
    log "Creating Stay N Alive Theme..."
    log "=== DEBUG: Starting main() ==="
    
    # Show current state
    log "=== DEBUG: Before cleanup ==="
    echo "Current directory: $(pwd)"
    echo "THEME_DIR: $THEME_DIR"
    
    # Verify source directory exists
    if [[ ! -d "src" ]]; then
        log_error "Source directory 'src' not found"
        exit 1
    fi
    
    # Verify all required source files exist
    local required_files=(
        "src/style.css"
        "src/theme.json"
        "src/index.php"
        "src/functions.php"
        "src/readme.txt"
        "src/inc/theme-setup.php"
    )
    
    for file in "${required_files[@]}"; do
        if [[ ! -f "$file" ]]; then
            log_error "Required source file not found: $file"
            exit 1
        fi
    done
    
    # Clean up existing directory
    cleanup_existing_directory || exit 1
    
    # Create directory structure
    create_directory_structure || exit 1
    
    # Copy template files
    copy_template_files || exit 1
    
    # Create checkpoint for template files
    create_checkpoint "template_files" || exit 1
    
    # Copy PHP files
    copy_php_files || exit 1
    create_checkpoint "php_files" || exit 1
    
    # Copy style.css
    copy_style_css || exit 1
    create_checkpoint "style_css" || exit 1
    
    # Copy theme.json
    copy_theme_json || exit 1
    create_checkpoint "theme_json" || exit 1
    
    # Copy CSS files
    copy_css_files || exit 1
    create_checkpoint "css_files" || exit 1
    
    # Copy JS files
    copy_js_files || exit 1
    create_checkpoint "js_files" || exit 1
    
    # Copy block patterns
    copy_block_patterns || exit 1
    create_checkpoint "block_patterns" || exit 1
    
    # Copy screenshot
    copy_screenshot || exit 1
    create_checkpoint "screenshot" || exit 1
    
    # Debug file paths
    debug_file_paths || exit 1
    
    # Create theme zip
    create_theme_zip || exit 1
    
    # Clean up checkpoint files
    cleanup_checkpoints || exit 1
    
    echo "Theme files created successfully!"
    echo "Theme zip created at: $THEME_ZIP"
}

# Execute main
verify_script_settings
main