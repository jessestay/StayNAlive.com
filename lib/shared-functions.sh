#!/usr/bin/env bash

echo "DEBUG: Starting shared-functions.sh"
echo "DEBUG: BASH_SOURCE=${BASH_SOURCE[*]}"
echo "DEBUG: Called from: $0"

# Define colors if not already defined
echo "DEBUG: Checking if GREEN is already defined..."
echo "DEBUG: Current GREEN value: ${GREEN:-undefined}"

if [[ -z "${GREEN:-}" ]]; then
    echo "DEBUG: GREEN not defined, defining now..."
    readonly GREEN='\033[0;32m'
    readonly BLUE='\033[0;34m'
    readonly RED='\033[0;31m'
    readonly YELLOW='\033[1;33m'
    readonly NC='\033[0m'
    echo "DEBUG: Color variables defined"
else
    echo "DEBUG: GREEN already defined as: $GREEN"
    echo "DEBUG: Called from script: $0"
    echo "DEBUG: Source stack: ${BASH_SOURCE[*]}"
fi

# Shared logging function
log() {
    echo -e "${BLUE}$1${NC}"
}

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

verify_script_settings() {
    # Verify pipefail is enabled
    if [[ "$SHELLOPTS" =~ "pipefail" ]]; then
        echo "pipefail        on"
    else
        echo "pipefail        off"
        return 1
    fi
    return 0
}

# Create directory structure
create_directory_structure() {
    local directories=(
        "assets/css/base"
        "assets/css/blocks"
        "assets/css/components"
        "assets/css/compatibility"
        "assets/css/utilities"
        "assets/js"
        "inc"
        "inc/classes"
        "languages"
        "parts"
        "patterns"
        "styles"
        "templates"
    )
    
    for dir in "${directories[@]}"; do
        if ! mkdir -p "${THEME_DIR}/${dir}"; then
            log_error "Failed to create directory: ${dir}"
            return 1
        fi
        
        # Create index.php in each directory
        if ! echo "<?php // Silence is golden." > "${THEME_DIR}/${dir}/index.php"; then
            log_error "Failed to create index.php in ${dir}"
            return 1
        fi
        echo "Created directory and index.php: ${dir}"
    done
    
    return 0
}

# Create checkpoint
create_checkpoint() {
    local stage="$1"
    local timestamp
    timestamp=$(date +%Y%m%d_%H%M%S)
    local checkpoint_file=".checkpoint_${stage}_${timestamp}"
    
    if ! touch "${THEME_DIR}/${checkpoint_file}"; then
        log_error "Failed to create checkpoint for stage: ${stage}"
        return 1
    fi
    
    echo "Creating checkpoint for stage: ${stage}"
    return 0
}

# Clean up checkpoints
cleanup_checkpoints() {
    echo "Cleaning up checkpoint files..."
    find "${THEME_DIR}" -name ".checkpoint_*" -type f -delete
    return 0
}

# Copy template files
copy_template_files() {
    echo "Copying template files..."
    echo "DEBUG: Current directory: $(pwd)"
    echo "DEBUG: Source directory contents:"
    ls -la src/parts/ src/templates/ src/patterns/
    
    local template_files=(
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
    
    # Copy each template file
    for file in "${template_files[@]}"; do
        echo "DEBUG: Copying $file..."
        if [[ ! -f "src/$file" ]]; then
            log_error "Source file missing: $file"
            echo "DEBUG: Tried to find: $(pwd)/src/$file"
            return 1
        fi
        
        cp "src/$file" "${THEME_DIR}/$file" || {
            log_error "Failed to copy $file"
            echo "DEBUG: From: $(pwd)/src/$file"
            echo "DEBUG: To: $(pwd)/${THEME_DIR}/$file"
            return 1
        }
        
        if [[ ! -f "${THEME_DIR}/$file" ]]; then
            log_error "File not found after copy: ${THEME_DIR}/$file"
            return 1
        fi
        echo "DEBUG: Successfully copied $file"
    done
    
    echo "DEBUG: Final theme directory contents:"
    ls -la "${THEME_DIR}/parts/" "${THEME_DIR}/templates/" "${THEME_DIR}/patterns/"
    
    # Copy critical files
    local critical_files=(
        "templates/front-page.html"
        "patterns/cta.html"
        "patterns/featured-post.html"
    )
    
    for file in "${critical_files[@]}"; do
        cp -v "src/$file" "${THEME_DIR}/$file" || {
            log_error "Failed to copy critical file: $file"
            return 1
        }
    done
    
    return 0
}

# Copy PHP files
copy_php_files() {
    echo "Copying PHP files..."
    
    local php_files=(
        "functions.php"
        "index.php"
        "inc/block-patterns.php"
        "inc/theme-setup.php"
        "inc/template-loader.php"
        "inc/security.php"
        "inc/performance.php"
        "inc/social-feeds.php"
        "inc/classes/class-theme-setup.php"
        "inc/classes/class-security.php"
        "inc/classes/class-performance.php"
        "inc/classes/class-social-feed.php"
    )
    
    for file in "${php_files[@]}"; do
        if ! cp "src/$file" "${THEME_DIR}/$file"; then
            log_error "Failed to copy PHP file: $file"
            return 1
        fi
    done
    
    return 0
}

# Copy style.css
copy_style_css() {
    if ! cp "src/style.css" "${THEME_DIR}/style.css"; then
        log_error "Failed to copy style.css"
        return 1
    fi
    return 0
}

# Copy theme.json
copy_theme_json() {
    if ! cp "src/theme.json" "${THEME_DIR}/theme.json"; then
        log_error "Failed to copy theme.json"
        return 1
    fi
    return 0
}

# Copy CSS files
copy_css_files() {
    echo "Copying CSS files..."
    
    echo "DEBUG: Current directory: $(pwd)"
    echo "DEBUG: Full path: $(readlink -f .)"
    echo "DEBUG: Directory contents:"
    ls -la
    
    echo "DEBUG: Listing source CSS directories:"
    ls -la src/assets/css/*/ || echo "ERROR: Cannot list source CSS directories"
    
    echo "DEBUG: Checking target CSS directories..."
    if [[ -d "${THEME_DIR}/assets/css" ]]; then
        ls -la "${THEME_DIR}/assets/css/*/" || echo "DEBUG: Target directories not yet populated (expected)"
    else
        echo "DEBUG: Target CSS directory structure not yet created (expected)"
    fi
    
    echo "DEBUG: Checking for StayNAlive.com directory:"
    ls -la StayNAlive.com/assets/css/blocks/ || echo "ERROR: Cannot list StayNAlive.com blocks directory"
    
    local css_files=(
        "assets/css/base/base.css"
        "assets/css/base/normalize.css"
        "assets/css/base/wordpress.css"
        "assets/css/compatibility/divi.css"
        "assets/css/components/author-bio.css"
        "assets/css/components/footer.css"
        "assets/css/components/header.css"
        "assets/css/components/link-bio.css"
        "assets/css/components/mobile-menu.css"
        "assets/css/components/social-feed.css"
        "assets/css/utilities/animations.css"
        "assets/css/editor-style.css"
        "assets/css/style.css"
    )
    
    echo "DEBUG: Copying regular CSS files..."
    for file in "${css_files[@]}"; do
        echo "DEBUG: Attempting to copy src/$file to ${THEME_DIR}/$file"
        echo "DEBUG: Source path exists: $([[ -f "src/$file" ]] && echo "Yes" || echo "No")"
        echo "DEBUG: Target directory exists: $([[ -d "$(dirname "${THEME_DIR}/$file")" ]] && echo "Yes" || echo "No")"
        
        if ! cp "src/$file" "${THEME_DIR}/$file"; then
            log_error "Failed to copy CSS file: $file"
            echo "DEBUG: Source exists: $([[ -f "src/$file" ]] && echo "Yes" || echo "No")"
            echo "DEBUG: Target directory exists: $([[ -d "$(dirname "${THEME_DIR}/$file")" ]] && echo "Yes" || echo "No")"
            return 1
        fi
        echo "DEBUG: Successfully copied $file"
    done
    
    # Handle custom-styles.css
    echo "DEBUG: Copying custom-styles.css..."
    echo "DEBUG: Checking for custom-styles.css in current directory"
    echo "DEBUG: Running find command..."
    find . -name "custom-styles.css" -ls || echo "DEBUG: find returned $?"
    
    # Try multiple possible locations
    local custom_styles_locations=(
        "assets/css/blocks/custom-styles.css"
        "StayNAlive.com/assets/css/blocks/custom-styles.css"
        "src/assets/css/blocks/custom-styles.css"
    )
    
    local found_custom_styles=""
    for loc in "${custom_styles_locations[@]}"; do
        echo "DEBUG: Checking location: $loc"
        if [[ -f "$loc" ]]; then
            echo "DEBUG: Found custom-styles.css at: $loc"
            found_custom_styles="$loc"
            break
        fi
    done
    
    if [[ -n "$found_custom_styles" ]]; then
        echo "DEBUG: Found custom-styles.css, attempting to copy..."
        if ! cp "$found_custom_styles" "${THEME_DIR}/assets/css/blocks/custom-styles.css"; then
            log_error "Failed to copy custom-styles.css"
            echo "DEBUG: Target directory exists: $([[ -d "${THEME_DIR}/assets/css/blocks" ]] && echo "Yes" || echo "No")"
            echo "DEBUG: Source file exists: $([[ -f "$found_custom_styles" ]] && echo "Yes" || echo "No")"
            echo "DEBUG: Source file contents:"
            cat "$found_custom_styles" || echo "ERROR: Cannot read source file"
            return 1
        fi
        echo "DEBUG: Successfully copied custom-styles.css"
    else
        echo "DEBUG: custom-styles.css not found in expected location"
        echo "DEBUG: Current directory structure:"
        find . -type d -name "blocks" -ls
        echo "DEBUG: Full directory tree:"
        find . -type f -name "*.css" -ls
        log_error "custom-styles.css not found in any expected location"
        return 1
    fi
    
    return 0
}

# Copy JS files
copy_js_files() {
    echo "Copying JS files..."
    
    local js_files=(
        "assets/js/animations.js"
        "assets/js/emoji-support.js"
        "assets/js/google-maps.js"
        "assets/js/sharethis.js"
        "assets/js/social-feed.js"
    )
    
    for file in "${js_files[@]}"; do
        if ! cp "src/$file" "${THEME_DIR}/$file"; then
            log_error "Failed to copy JS file: $file"
            return 1
        fi
    done
    
    return 0
}

# Copy block patterns
copy_block_patterns() {
    echo "Copying block patterns..."
    
    local pattern_files=(
        "patterns/author-bio.html"
        "patterns/bio-link-button.html"
        "patterns/cta.html"
        "patterns/featured-post.html"
        "patterns/social-grid.html"
    )
    
    for file in "${pattern_files[@]}"; do
        if ! cp "src/$file" "${THEME_DIR}/$file"; then
            log_error "Failed to copy pattern file: $file"
            return 1
        fi
    done
    
    return 0
}

# Copy screenshot
copy_screenshot() {
    echo "DEBUG: Checking for screenshot.png..."
    echo "DEBUG: Current directory: $(pwd)"
    echo "DEBUG: Looking for screenshot in:"
    echo "  - src/screenshot.png"
    echo "  - screenshot.png"
    echo "  - StayNAlive.com/screenshot.png"
    
    # Try multiple locations
    local screenshot_locations=(
        "src/screenshot.png"
        "screenshot.png"
        "StayNAlive.com/screenshot.png"
    )
    
    for loc in "${screenshot_locations[@]}"; do
        echo "DEBUG: Checking $loc"
        if [[ -f "$loc" ]]; then
            echo "DEBUG: Found screenshot at $loc"
            if cp "$loc" "${THEME_DIR}/screenshot.png"; then
                echo "DEBUG: Successfully copied screenshot"
                return 0
            fi
        fi
    done
    
    # If we get here, no screenshot was found
    echo "WARNING: No screenshot.png found - this is not a critical error"
    echo "DEBUG: Theme can still function without a screenshot"
    return 0
}

# Debug file paths
debug_file_paths() {
    echo "Debugging file paths..."
    echo "Theme directory: $THEME_DIR"
    
    echo "Checking theme-setup.php..."
    local setup_file="${THEME_DIR}/inc/theme-setup.php"
    if [[ -f "$setup_file" ]]; then
        echo "File exists: $setup_file"
        ls -l "$setup_file"
        echo "File contents first 10 lines:"
        head -n 10 "$setup_file"
    else
        log_error "theme-setup.php not found"
        return 1
    fi
    
    echo "Directory structure:"
    find "$THEME_DIR" -type d -print
    
    echo "All PHP files:"
    find "$THEME_DIR" -name "*.php" -type f -ls
    
    echo "Checking functions.php require statement:"
    grep -n "require_once.*theme-setup.php" "${THEME_DIR}/functions.php"
    
    return 0
}

# Create theme zip
create_theme_zip() {
    echo "Creating theme zip..."
    
    echo "DEBUG: Verifying theme directory contents before zipping..."
    ls -la "${THEME_DIR}/parts/" "${THEME_DIR}/templates/" "${THEME_DIR}/patterns/"
    
    # Verify required files exist
    local required_files=(
        "style.css"
        "theme.json"
        "functions.php"
        "parts/header.html"
        "parts/footer.html"
    )
    
    for file in "${required_files[@]}"; do
        echo "DEBUG: Checking for ${THEME_DIR}/$file"
        if [[ ! -f "${THEME_DIR}/$file" ]]; then
            log_error "Missing required file: $file"
            return 1
        fi
    done
    
    echo "DEBUG: Attempting to create zip file..."
    
    # First try to ensure all file handles are closed
    echo "DEBUG: Ensuring files are not in use..."
    if [[ "$OSTYPE" == "msys" || "$OSTYPE" == "cygwin" ]]; then
        # Force close any open handles
        powershell.exe -Command "
            \$ErrorActionPreference = 'SilentlyContinue'
            [System.GC]::Collect()
            [System.GC]::WaitForPendingFinalizers()
        "
    fi
    
    # Add a small delay to ensure handles are released
    sleep 2
    
    if command -v zip >/dev/null 2>&1; then
        echo "DEBUG: Using zip command..."
        if ! zip -r "$THEME_ZIP" "$THEME_DIR"; then
            log_error "Failed to create zip file"
            return 1
        fi
    elif [[ "$OSTYPE" == "msys" || "$OSTYPE" == "cygwin" ]]; then
        echo "DEBUG: zip not found, using PowerShell Compress-Archive..."
        local max_retries=3
        local retry_count=0
        local success=false
        
        while (( retry_count < max_retries )) && [[ "$success" != "true" ]]; do
            echo "DEBUG: Attempt $((retry_count + 1)) of $max_retries"
            
            # Convert paths
            local win_source="${THEME_DIR//\//\\}"
            local win_dest="${THEME_ZIP//\//\\}"
            
            if ! powershell.exe -Command "
                \$ErrorActionPreference = 'Stop'
                Write-Host 'DEBUG: Cleaning up any open handles...'
                [System.GC]::Collect()
                [System.GC]::WaitForPendingFinalizers()
                
                Write-Host 'DEBUG: Starting compression...'
                Compress-Archive -Path '$win_source\\*' -DestinationPath '$win_dest' -Force
                Write-Host 'DEBUG: Compression completed'
                \$true
            "; then
                echo "DEBUG: Compression failed on attempt $((retry_count + 1))"
                (( retry_count++ ))
                sleep 3  # Wait before retrying
            else
                success=true
                break
            fi
        done
        
        if [[ "$success" != "true" ]]; then
            log_error "Failed to create zip file using PowerShell"
            return 1
        fi
    else
        log_error "No zip command found and not on Windows - cannot create zip file"
        return 1
    fi
    
    echo "DEBUG: Verifying zip file contents..."
    echo "DEBUG: Zip file size: $(stat -f%z "$THEME_ZIP" 2>/dev/null || stat -c%s "$THEME_ZIP" 2>/dev/null || echo "unknown")"
    
    if [[ ! -f "$THEME_ZIP" ]]; then
        log_error "Zip file was not created"
        return 1
    fi
    
    echo "DEBUG: Zip file created successfully at: $THEME_ZIP"
    return 0
}

# Shared verification functions
verify_theme_files() {
    echo "DEBUG: Starting theme file verification..."
    
    # Debug current state
    echo "DEBUG: Current working directory: $(pwd)"
    echo "DEBUG: THEME_DIR value: $THEME_DIR"
    echo "DEBUG: Source directory contents:"
    ls -la src/ || echo "ERROR: Cannot list src directory"
    
    # Debug required files
    echo "DEBUG: Checking required files:"
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
        echo "DEBUG: Checking for src/$file"
        if [[ ! -f "src/$file" ]]; then
            log_error "Required source file not found: src/$file"
            return 1
        fi
        echo "DEBUG: Found src/$file"
    done
    
    return 0
}

verify_theme_functions() {
    echo "Verifying theme function definitions..."
    
    # Create inc directory if needed
    if ! mkdir -p "${THEME_DIR}/inc"; then
        log_error "Failed to create inc directory"
        return 1
    fi
    
    return 0
}

verify_functions_php() {
    echo "Verifying functions.php..."
    
    echo "DEBUG: Checking functions.php contents:"
    cat "${THEME_DIR}/functions.php"
    
    if [[ ! -f "${THEME_DIR}/functions.php" ]]; then
        log_error "functions.php not found"
        return 1
    fi
    
    # Verify required functions exist
    local required_functions=(
        "staynalive_theme_setup"
        "staynalive_template_loader"
        "staynalive_register_block_patterns"
    )
    
    for func in "${required_functions[@]}"; do
        echo "DEBUG: Checking for function: $func"
        if ! grep -q "function ${func}" "${THEME_DIR}/functions.php"; then
            log_error "Missing required function: ${func}"
            return 1
        fi
        echo "DEBUG: Found function: $func"
    done
    
    return 0
}

verify_theme_setup() {
    echo "Verifying theme setup..."
    
    local setup_file="${THEME_DIR}/inc/theme-setup.php"
    if [[ ! -f "$setup_file" ]]; then
        log_error "theme-setup.php not found"
        return 1
    fi
    
    # Verify and update namespaces in all PHP files
    echo "DEBUG: Checking namespaces and naming conventions..."
    local php_files=(
        "inc/theme-setup.php"
        "inc/classes/class-theme-setup.php"
        "inc/classes/class-security.php"
        "inc/classes/class-performance.php"
        "inc/classes/class-social-feed.php"
        "functions.php"
        "inc/block-patterns.php"
        "inc/template-loader.php"
        "inc/security.php"
        "inc/performance.php"
        "inc/social-feeds.php"
    )
    
    for file in "${php_files[@]}"; do
        local full_path="${THEME_DIR}/$file"
        echo "DEBUG: Checking naming conventions in $file"
        
        if [[ -f "$full_path" ]]; then
            # Show before state
            echo "DEBUG: Current namespace in $file:"
            grep -E "(namespace|@package) (StayNAlive|Stay_N_Alive)" "$full_path" || echo "No matching namespace found"
            
            # Check for old formats
            if grep -q -E "(namespace|@package|function|class|add_filter|add_action) (StayNAlive|Stay_N_Alive)" "$full_path" || \
               grep -q -E "STAY_N_ALIVE|StayNAlive_|Stay_N_Alive_" "$full_path"; then
                echo "DEBUG: Found old naming conventions in $file, updating..."
                
                # Update namespaces and package names
                sed -i \
                    -e 's/namespace StayNAlive/namespace Staynalive/g' \
                    -e 's/namespace Stay_N_Alive/namespace Staynalive/g' \
                    -e 's/@package Stay_N_Alive/@package Staynalive/g' \
                    -e 's/STAY_N_ALIVE/STAYNALIVE/g' \
                    -e 's/StayNAlive_/Staynalive_/g' \
                    -e 's/Stay_N_Alive_/Staynalive_/g' \
                    -e 's/function stay_n_alive_/function staynalive_/g' \
                    -e 's/function StayNAlive_/function staynalive_/g' \
                    -e 's/add_filter(['"'"'"])stay_n_alive_/add_filter(\1staynalive_/g' \
                    -e 's/add_filter(['"'"'"])StayNAlive_/add_filter(\1staynalive_/g' \
                    -e 's/add_action(['"'"'"])stay_n_alive_/add_action(\1staynalive_/g' \
                    -e 's/add_action(['"'"'"])StayNAlive_/add_action(\1staynalive_/g' \
                    "$full_path"
                
                echo "DEBUG: Updated naming conventions in $file"
                echo "DEBUG: New namespace:"
                grep -E "(namespace|@package) Staynalive" "$full_path" || echo "WARNING: No namespace found after update"
            fi
        else
            log_error "PHP file not found: $file"
            return 1
        fi
    done
    
    # Verify required theme supports
    local required_supports=(
        "add_theme_support.*automatic-feed-links"
        "add_theme_support.*title-tag"
        "add_theme_support.*post-thumbnails"
        "add_theme_support.*align-wide"
        "add_theme_support.*responsive-embeds"
    )
    
    for support in "${required_supports[@]}"; do
        if ! grep -q "$support" "$setup_file"; then
            log_error "Missing required theme support: $support"
            return 1
        fi
    done
    
    return 0
}

verify_template_loader() {
    echo "Verifying template loader..."
    
    local loader_file="${THEME_DIR}/inc/template-loader.php"
    if [[ ! -f "$loader_file" ]]; then
        log_error "template-loader.php not found"
        return 1
    fi
    
    # Verify template loader function
    if ! grep -q "function staynalive_template_loader" "$loader_file"; then
        log_error "Missing template loader function"
        return 1
    fi
    
    return 0
}

verify_block_patterns() {
    echo "Verifying block patterns..."
    
    local patterns_file="${THEME_DIR}/inc/block-patterns.php"
    if [[ ! -f "$patterns_file" ]]; then
        log_error "block-patterns.php not found"
        return 1
    fi
    
    # Verify pattern registration
    if ! grep -q "register_block_pattern_category.*staynalive" "$patterns_file"; then
        log_error "Missing pattern category registration"
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
    
    # Verify files exist and have proper block structure
    for file in "${template_files[@]}" "${pattern_files[@]}" "${part_files[@]}"; do
        if [[ ! -f "${THEME_DIR}/$file" ]]; then
            log_error "Missing HTML file: $file"
            return 1
        fi
        
        # Check for proper block structure
        if ! grep -q "<!-- wp:" "${THEME_DIR}/$file"; then
            log_error "Missing block structure in $file"
            return 1
        fi
    done
    
    return 0
}

# Clean up existing directory
cleanup_existing_directory() {
    if [[ -d "$THEME_DIR" ]]; then
        log "Cleaning up directory: $THEME_DIR"
        echo "DEBUG: Attempting to remove directory..."
        
        # On Windows, we need to handle permissions differently
        if [[ "$OSTYPE" == "msys" || "$OSTYPE" == "cygwin" ]]; then
            echo "DEBUG: Windows system detected, using force removal"
            
            # Convert path to Windows format
            local win_path="${THEME_DIR//\//\\}"
            
            # First try to remove read-only attributes
            echo "DEBUG: Removing read-only attributes..."
            if [[ -d "$THEME_DIR" ]]; then
                echo "DEBUG: Running: attrib -R \"$win_path\\*\" /S"
                cmd //c "attrib -R \"$win_path\\*\" /S" || {
                    echo "DEBUG: attrib command failed (expected if directory is new), continuing..."
                }
            else
                echo "DEBUG: Directory does not exist, skipping cleanup"
                return 0
            fi
            
            # Then try to remove the directory
            echo "DEBUG: Attempting directory removal..."
            rm -rf "${THEME_DIR}" || {
                echo "DEBUG: First rm attempt failed, trying rmdir"
                echo "DEBUG: Running: rmdir /s /q \"$win_path\""
                cmd //c "rmdir /s /q \"$win_path\"" || {
                    echo "DEBUG: Windows rmdir failed too"
                    echo "DEBUG: Last attempt - using PowerShell..."
                    powershell.exe -Command "
                        \$ErrorActionPreference = 'Stop'
                        if (Test-Path '$win_path') {
                            Remove-Item -Path '$win_path' -Recurse -Force
                            Write-Host 'PowerShell removal succeeded'
                        } else {
                            Write-Host 'Directory already removed'
                        }
                    " || {
                        echo "DEBUG: PowerShell removal failed"
                        return 1
                    }
                }
            }
        else
            rm -rf "$THEME_DIR"
        fi
        
        if [[ -d "$THEME_DIR" ]]; then
            log_error "Failed to remove directory: $THEME_DIR"
            echo "DEBUG: Directory still exists after removal attempt"
            ls -la "$THEME_DIR"
            return 1
        fi
        echo "DEBUG: Directory successfully removed"
    else
        echo "DEBUG: Directory does not exist, skipping cleanup"
    fi
    return 0
}

# ... other shared functions ... 