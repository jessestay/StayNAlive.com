#!/usr/bin/env bash

# Verify proper shebang interpretation
if [ -z "$BASH_VERSION" ]; then
    echo "Error: This script requires bash"
    exit 1
fi

# WordPress Theme Installation Script
# Creates a complete WordPress theme with all necessary files and structure
# Includes validation, error handling, and checkpoints
# Dependencies: bash, php, powershell.exe (on Windows), zip
# Author: Jesse Stay
# Version: 1.0.0

# Exit on error, undefined variables, and pipe failures
set -euo pipefail

# Description: Verifies script is running with required safety settings
# Arguments: None
# Returns: 0 on success, exits with 1 on failure
# Dependencies: None
# Example: verify_script_settings
verify_script_settings() {
    if [[ ! "$-" =~ e ]]; then
        echo -e "${RED}Error: Script must run with 'set -e'${NC}"
        exit 1
    fi
    if [[ ! "$-" =~ u ]]; then
        echo -e "${RED}Error: Script must run with 'set -u'${NC}"
        exit 1
    fi
    if [[ ! "$-" =~ o\ pipefail || ! "$SHELLOPTS" =~ pipefail ]]; then
        echo -e "${RED}Error: Script must run with 'set -o pipefail'${NC}"
        exit 1
    fi
}

# Call verify_script_settings before any other code
verify_script_settings

# Colors for output
readonly GREEN='\033[0;32m'
readonly BLUE='\033[0;34m'
readonly RED='\033[0;31m'
readonly YELLOW='\033[1;33m'
readonly NC='\033[0m'

# Theme directory name
readonly THEME_DIR="stay-n-alive"

# Description: Main execution function that orchestrates theme creation
# Arguments: None
# Returns: 0 on success, exits with 1 on failure
# Dependencies: All other functions
# Example: main
main() {
    log "Creating Stay N Alive Theme..."
    log "=== DEBUG: Starting main() ==="
    
    # Check required commands first
    check_required_commands || {
        echo -e "${RED}Error: Missing required commands${NC}"
        exit 1
    }
    
    # Clean up existing theme directory
    if [ -d "${THEME_DIR}" ]; then
        debug_state "Before cleanup"
        cleanup_directory "${THEME_DIR}" || {
            echo -e "${RED}Error: Could not clean up existing theme directory${NC}"
            exit 1
        }
    }
    
    # Create and verify directory structure first
    verify_directory_structure "${THEME_DIR}" || {
        echo -e "${RED}Error: Could not verify directory structure${NC}"
        exit 1
    }
    
    # Create all files in order
    create_directories || {
        echo -e "${RED}Error: Could not create directories${NC}"
        exit 1
    }
    create_checkpoint "directories"
    
    create_php_files || {
        echo -e "${RED}Error: Could not create PHP files${NC}"
        exit 1
    }
    create_checkpoint "php_files"
    
    create_style_css || {
        echo -e "${RED}Error: Could not create style.css${NC}"
        exit 1
    }
    create_checkpoint "style_css"
    
    create_theme_json || {
        echo -e "${RED}Error: Could not create theme.json${NC}"
        exit 1
    }
    create_checkpoint "theme_json"
    
    create_all_templates || {
        echo -e "${RED}Error: Could not create templates${NC}"
        exit 1
    }
    create_checkpoint "templates"
    
    create_template_parts || {
        echo -e "${RED}Error: Could not create template parts${NC}"
        exit 1
    }
    create_checkpoint "template_parts"
    
    create_css_files || {
        echo -e "${RED}Error: Could not create CSS files${NC}"
        exit 1
    }
    create_checkpoint "css_files"
    
    create_all_js_files || {
        echo -e "${RED}Error: Could not create JS files${NC}"
        exit 1
    }
    create_checkpoint "js_files"
    
    create_block_patterns || {
        echo -e "${RED}Error: Could not create block patterns${NC}"
        exit 1
    }
    create_checkpoint "block_patterns"
    
    create_screenshot || {
        echo -e "${RED}Error: Could not create screenshot${NC}"
        exit 1
    }
    create_checkpoint "screenshot"
    
    # Verify everything was created correctly
    debug_file_paths "${THEME_DIR}" || exit 1
    
    # Create and verify zip
    create_zip "${THEME_DIR}" || exit 1
    
    verify_zip_contents "stay-n-alive.zip" || {
        echo -e "${RED}Error: Zip verification failed${NC}"
        exit 1
    }
    
    verify_theme_package "stay-n-alive.zip" || {
        echo -e "${RED}Error: Theme package verification failed${NC}"
        exit 1
    }
    
    # Clean up checkpoints after successful completion
    cleanup_checkpoints
    
    log "Theme files created successfully!"
    echo -e "Theme zip created at: ${BLUE}stay-n-alive.zip${NC}"
}

# Description: Logs a message with color formatting
# Arguments:
#   $1 - Message to log
# Returns: None
# Dependencies: echo
# Example: log "Starting process..."
log() {
    echo -e "${BLUE}$1${NC}"
}

# Function to create directories
# Description: Creates all required theme directories with index.php files
# Arguments: None
# Returns: 0 on success, 1 on failure
# Dependencies: mkdir, echo
create_directories() {
    local -r dirs=(
        "assets/css/base"
        "assets/css/blocks"
        "assets/css/components"
        "assets/css/compatibility"
        "assets/css/utilities"
        "assets/js"
        "inc"           # Make sure this is listed
        "inc/classes"
        "languages"
        "parts"
        "patterns"
        "styles"
        "templates"
    )
    
    # First verify all directories are unique
    local unique_dirs=()
    for dir in "${dirs[@]}"; do
        if [[ " ${unique_dirs[@]} " =~ " ${dir} " ]]; then
            echo -e "${RED}Error: Duplicate directory found: ${dir}${NC}"
            return 1
        fi
        unique_dirs+=("$dir")
    done
    
    # Create directories and index.php files
    for dir in "${dirs[@]}"; do
        # Create directory
        mkdir -p "${THEME_DIR}/${dir}"
        
        # Create index.php in the directory
        echo "<?php // Silence is golden" > "${THEME_DIR}/${dir}/index.php"
        
        # Verify directory and index.php were created
        if [[ ! -d "${THEME_DIR}/${dir}" ]]; then
            echo -e "${RED}Error: Failed to create directory: ${dir}${NC}"
            return 1
        fi
        if [[ ! -f "${THEME_DIR}/${dir}/index.php" ]]; then
            echo -e "${RED}Error: Failed to create index.php in: ${dir}${NC}"
            return 1
        fi
        
        echo -e "${GREEN}Created directory and index.php: ${dir}${NC}"
    done
    
    # Verify all directories have content
    local empty_dirs=()
    while IFS= read -r -d '' dir; do
        if [[ -z "$(ls -A "$dir")" ]]; then
            empty_dirs+=("$dir")
        fi
    done < <(find "${THEME_DIR}" -type d -print0)
    
    if [[ ${#empty_dirs[@]} -gt 0 ]]; then
        echo -e "${RED}Error: Found empty directories:${NC}"
        printf '%s\n' "${empty_dirs[@]}"
        return 1
    fi
    
    return 0
}

# Description: Creates and validates the theme's style.css file
# Arguments: None
# Returns: 0 on success, 1 on failure
# Dependencies: cp, grep
# Example: create_style_css
create_style_css() {
    cp "src/style.css" "${THEME_DIR}/style.css" || {
        echo -e "${RED}Error: Could not copy style.css${NC}"
        return 1
    }

    # Verify the file was created correctly
    if ! grep -q "^Theme Name:" "${THEME_DIR}/style.css"; then
        echo -e "${RED}Error: Theme Name not found in style.css header${NC}"
        exit 1
    fi
}

# Description: Creates and validates the theme's theme.json file
# Arguments: None
# Returns: 0 on success, 1 on failure
# Dependencies: cp
# Example: create_theme_json
create_theme_json() {
    cp "src/theme.json" "${THEME_DIR}/theme.json" || {
        echo -e "${RED}Error: Could not copy theme.json${NC}"
        return 1
    }
}

# Description: Creates and validates all template files
# Arguments: None
# Returns: 0 on success, 1 on failure
# Dependencies: cp
# Example: create_all_templates
create_all_templates() {
    cp "src/templates/single.html" "${THEME_DIR}/templates/single.html" || {
        echo -e "${RED}Error: Could not copy single.html${NC}"
        return 1
    }
    
    cp "src/templates/archive.html" "${THEME_DIR}/templates/archive.html" || {
        echo -e "${RED}Error: Could not copy archive.html${NC}"
        return 1
    }
    
    cp "src/templates/404.html" "${THEME_DIR}/templates/404.html" || {
        echo -e "${RED}Error: Could not copy 404.html${NC}"
        return 1
    }
    
    cp "src/templates/search.html" "${THEME_DIR}/templates/search.html" || {
        echo -e "${RED}Error: Could not copy search.html${NC}"
        return 1
    }
    
    cp "src/templates/category.html" "${THEME_DIR}/templates/category.html" || {
        echo -e "${RED}Error: Could not copy category.html${NC}"
        return 1
    }
    
    cp "src/templates/tag.html" "${THEME_DIR}/templates/tag.html" || {
        echo -e "${RED}Error: Could not copy tag.html${NC}"
        return 1
    }
    
    cp "src/templates/author.html" "${THEME_DIR}/templates/author.html" || {
        echo -e "${RED}Error: Could not copy author.html${NC}"
        return 1
    }
    
    cp "src/templates/index.html" "${THEME_DIR}/templates/index.html" || {
        echo -e "${RED}Error: Could not copy index.html${NC}"
        return 1
    }
    
    cp "src/templates/link-bio.html" "${THEME_DIR}/templates/link-bio.html" || {
        echo -e "${RED}Error: Could not copy link-bio.html${NC}"
        return 1
    }
}

# Description: Creates and validates all template part files
# Arguments: None
# Returns: 0 on success, 1 on failure
# Dependencies: cp
# Example: create_template_parts
create_template_parts() {
    cp "src/parts/header.html" "${THEME_DIR}/parts/header.html" || {
        echo -e "${RED}Error: Could not copy header.html${NC}"
        return 1
    }
    
    cp "src/parts/footer.html" "${THEME_DIR}/parts/footer.html" || {
        echo -e "${RED}Error: Could not copy footer.html${NC}"
        return 1
    }
    
    cp "src/parts/content.php" "${THEME_DIR}/parts/content.php" || {
        echo -e "${RED}Error: Could not copy content.php${NC}"
        return 1
    }
    
    cp "src/parts/content-none.php" "${THEME_DIR}/parts/content-none.php" || {
        echo -e "${RED}Error: Could not copy content-none.php${NC}"
        return 1
    }
}

# Description: Creates and validates all CSS files for the theme
# Arguments: None
# Returns: 0 on success, 1 on failure
# Dependencies: cp
# Example: create_css_files
create_css_files() {
    cp "src/assets/css/style.css" "${THEME_DIR}/assets/css/style.css" || {
        echo -e "${RED}Error: Could not copy style.css${NC}"
        return 1
    }

    cp "src/assets/css/base/wordpress.css" "${THEME_DIR}/assets/css/base/wordpress.css" || {
        echo -e "${RED}Error: Could not copy wordpress.css${NC}"
        return 1
    }

    cp "src/assets/css/editor-style.css" "${THEME_DIR}/assets/css/editor-style.css" || {
        echo -e "${RED}Error: Could not copy editor-style.css${NC}"
        return 1
    }

    cp "src/assets/css/base/base.css" "${THEME_DIR}/assets/css/base/base.css" || {
        echo -e "${RED}Error: Could not copy base.css${NC}"
        return 1
    }

    cp "src/assets/css/base/normalize.css" "${THEME_DIR}/assets/css/base/normalize.css" || {
        echo -e "${RED}Error: Could not copy normalize.css${NC}"
        return 1
    }

    cp "src/assets/css/components/header.css" "${THEME_DIR}/assets/css/components/header.css" || {
        echo -e "${RED}Error: Could not copy header.css${NC}"
        return 1
    }

    cp "src/assets/css/components/footer.css" "${THEME_DIR}/assets/css/components/footer.css" || {
        echo -e "${RED}Error: Could not copy footer.css${NC}"
        return 1
    }

    cp "src/assets/css/components/mobile-menu.css" "${THEME_DIR}/assets/css/components/mobile-menu.css" || {
        echo -e "${RED}Error: Could not copy mobile-menu.css${NC}"
        return 1
    }

    cp "src/assets/css/utilities/animations.css" "${THEME_DIR}/assets/css/utilities/animations.css" || {
        echo -e "${RED}Error: Could not copy animations.css${NC}"
        return 1
    }

    cp "src/assets/css/compatibility/divi.css" "${THEME_DIR}/assets/css/compatibility/divi.css" || {
        echo -e "${RED}Error: Could not copy divi.css${NC}"
        return 1
    }

    cp "src/assets/css/compatibility/divi-legacy.css" "${THEME_DIR}/assets/css/compatibility/divi-legacy.css" || {
        echo -e "${RED}Error: Could not copy divi-legacy.css${NC}"
        return 1
    }

    cp "src/assets/css/components/link-bio.css" "${THEME_DIR}/assets/css/components/link-bio.css" || {
        echo -e "${RED}Error: Could not copy link-bio.css${NC}"
        return 1
    }

    cp "src/assets/css/components/social-feed.css" "${THEME_DIR}/assets/css/components/social-feed.css" || {
        echo -e "${RED}Error: Could not copy social-feed.css${NC}"
        return 1
    }

    cp "src/assets/css/components/author-bio.css" "${THEME_DIR}/assets/css/components/author-bio.css" || {
        echo -e "${RED}Error: Could not copy author-bio.css${NC}"
        return 1
    }
}

# Description: Creates and validates all JavaScript files for the theme
# Arguments: None
# Returns: 0 on success, 1 on failure
# Dependencies: cp
# Example: create_all_js_files
create_all_js_files() {
    cp "src/assets/js/social-feed.js" "${THEME_DIR}/assets/js/social-feed.js" || {
        echo -e "${RED}Error: Could not copy social-feed.js${NC}"
        return 1
    }

    cp "src/assets/js/animations.js" "${THEME_DIR}/assets/js/animations.js" || {
        echo -e "${RED}Error: Could not copy animations.js${NC}"
        return 1
    }

    cp "src/assets/js/emoji-support.js" "${THEME_DIR}/assets/js/emoji-support.js" || {
        echo -e "${RED}Error: Could not copy emoji-support.js${NC}"
        return 1
    }

    cp "src/assets/js/google-maps.js" "${THEME_DIR}/assets/js/google-maps.js" || {
        echo -e "${RED}Error: Could not copy google-maps.js${NC}"
        return 1
    }

    cp "src/assets/js/sharethis.js" "${THEME_DIR}/assets/js/sharethis.js" || {
        echo -e "${RED}Error: Could not copy sharethis.js${NC}"
        return 1
    }
}

# Description: Creates and validates all block pattern files
# Arguments: None
# Returns: 0 on success, 1 on failure
# Dependencies: cp
# Example: create_block_patterns
create_block_patterns() {
    cp "src/patterns/bio-link-button.html" "${THEME_DIR}/patterns/bio-link-button.html" || {
        echo -e "${RED}Error: Could not copy bio-link-button.html${NC}"
        return 1
    }
    
    cp "src/patterns/social-grid.html" "${THEME_DIR}/patterns/social-grid.html" || {
        echo -e "${RED}Error: Could not copy social-grid.html${NC}"
        return 1
    }
    
    cp "src/patterns/author-bio.html" "${THEME_DIR}/patterns/author-bio.html" || {
        echo -e "${RED}Error: Could not copy author-bio.html${NC}"
        return 1
    }
}

# Description: Creates and validates PHP files for the theme
# Arguments: None
# Returns: 0 on success, 1 on failure
# Dependencies: cp, mkdir, php, grep
# Example: create_php_files
create_php_files() {
    cp "src/index.php" "${THEME_DIR}/index.php" || {
        echo -e "${RED}Error: Could not copy index.php${NC}"
        return 1
    }
    
    cp "src/functions.php" "${THEME_DIR}/functions.php" || {
        echo -e "${RED}Error: Could not copy functions.php${NC}"
        return 1
    }
    
    cp "src/readme.txt" "${THEME_DIR}/readme.txt" || {
        echo -e "${RED}Error: Could not copy readme.txt${NC}"
        return 1
    }

    # Create inc directory if it doesn't exist
    mkdir -p "${THEME_DIR}/inc" || {
        echo -e "${RED}Error: Could not create inc directory${NC}"
        return 1
    }

    # Copy inc files
    cp "src/inc/theme-setup.php" "${THEME_DIR}/inc/theme-setup.php" || {
        echo -e "${RED}Error: Could not copy theme-setup.php${NC}"
        return 1
    }

    cp "src/inc/security.php" "${THEME_DIR}/inc/security.php" || {
        echo -e "${RED}Error: Could not copy security.php${NC}"
        return 1
    }

    cp "src/inc/performance.php" "${THEME_DIR}/inc/performance.php" || {
        echo -e "${RED}Error: Could not copy performance.php${NC}"
        return 1
    }

    cp "src/inc/social-feeds.php" "${THEME_DIR}/inc/social-feeds.php" || {
        echo -e "${RED}Error: Could not copy social-feeds.php${NC}"
        return 1
    }

    cp "src/inc/template-loader.php" "${THEME_DIR}/inc/template-loader.php" || {
        echo -e "${RED}Error: Could not copy template-loader.php${NC}"
        return 1
    }

    cp "src/inc/block-patterns.php" "${THEME_DIR}/inc/block-patterns.php" || {
        echo -e "${RED}Error: Could not copy block-patterns.php${NC}"
        return 1
    }

    # Create inc/classes directory if it doesn't exist
    mkdir -p "${THEME_DIR}/inc/classes" || {
        echo -e "${RED}Error: Could not create inc/classes directory${NC}"
        return 1
    }

    # Copy class files
    cp "src/inc/classes/class-theme-setup.php" "${THEME_DIR}/inc/classes/class-theme-setup.php" || {
        echo -e "${RED}Error: Could not copy class-theme-setup.php${NC}"
        return 1
    }

    cp "src/inc/classes/class-social-feed.php" "${THEME_DIR}/inc/classes/class-social-feed.php" || {
        echo -e "${RED}Error: Could not copy class-social-feed.php${NC}"
        return 1
    }

    cp "src/inc/classes/class-performance.php" "${THEME_DIR}/inc/classes/class-performance.php" || {
        echo -e "${RED}Error: Could not copy class-performance.php${NC}"
        return 1
    }

    cp "src/inc/classes/class-security.php" "${THEME_DIR}/inc/classes/class-security.php" || {
        echo -e "${RED}Error: Could not copy class-security.php${NC}"
        return 1
    }

    # Verify PHP files
    for file in index.php functions.php inc/*.php; do
        if ! php -l "${THEME_DIR}/${file}" > /dev/null 2>&1; then
            echo -e "${RED}Error: PHP syntax error in ${file}${NC}"
            return 1
        fi
    done

    # Verify file contents
    if ! grep -q "Stay_N_Alive" "${THEME_DIR}/functions.php"; then
        echo -e "${RED}Error: functions.php missing theme package name${NC}"
        return 1
    fi

    if ! grep -q "get_header" "${THEME_DIR}/index.php"; then
        echo -e "${RED}Error: index.php missing required WordPress functions${NC}"
        return 1
    fi

    if ! grep -q "=== Stay N Alive ===" "${THEME_DIR}/readme.txt"; then
        echo -e "${RED}Error: readme.txt missing theme header${NC}"
        return 1
    fi

    return 0
}

# Description: Creates a screenshot for the theme using PowerShell
# Arguments: None
# Returns: 0 on success, 1 on failure
# Dependencies: PowerShell with System.Drawing
# Example: create_screenshot
create_screenshot() {
    run_powershell "
        Add-Type -AssemblyName System.Drawing;
        \$bmp = New-Object System.Drawing.Bitmap 1200,900;
        \$g = [System.Drawing.Graphics]::FromImage(\$bmp);
        \$g.Clear([System.Drawing.Color]::White);
        \$font = New-Object System.Drawing.Font('Arial', 48);
        \$brush = [System.Drawing.Brushes]::Black;
        \$text = 'Stay N Alive';
        \$size = \$g.MeasureString(\$text, \$font);
        \$x = (\$bmp.Width - \$size.Width) / 2;
        \$y = (\$bmp.Height - \$size.Height) / 2;
        \$g.DrawString(\$text, \$font, \$brush, \$x, \$y);
        \$bmp.Save('${THEME_DIR}/screenshot.png');
        \$g.Dispose();
        \$bmp.Dispose();
    " "Could not create screenshot"
}

# Description: Creates a zip file of the theme directory
# Arguments:
#   $1 - Theme directory path to zip
# Returns: 0 on success, 1 on failure
# Dependencies: cd, zip, create_zip_powershell
# Example: create_zip "theme-dir"
create_zip() {
    if [[ -z "$1" ]]; then
        echo -e "${RED}Error: theme_dir argument is required${NC}"
        return 1
    }
    local theme_dir="$1"
    echo "Creating theme zip file..."
    
    cd "$(dirname "$theme_dir")" || {
        echo -e "${RED}Error: Could not change to theme parent directory${NC}"
        return 1
    }
    
    if [[ "$OSTYPE" == "msys" || "$OSTYPE" == "cygwin" ]]; then
        create_zip_powershell "$(basename "$theme_dir")" "stay-n-alive.zip" || {
            echo -e "${RED}Error: Could not create zip file${NC}"
            cd - >/dev/null
            return 1
        }
    else
        # Unix environment
        zip -r "stay-n-alive.zip" "$(basename "$theme_dir")" -x "*/\.*" || {
            echo -e "${RED}Error: Could not create zip file${NC}"
            cd - >/dev/null
            return 1
        }
    fi
    
    cd - >/dev/null
    return 0
}

# Description: Verifies the theme package zip file
# Arguments:
#   $1 - Zip file path to verify
# Returns: 0 on success, 1 on failure
# Dependencies: PowerShell
# Example: verify_theme_package "theme.zip"
verify_theme_package() {
    if [[ -z "$1" ]]; then
        echo -e "${RED}Error: zip_file argument is required${NC}"
        return 1
    }
    local zip_file="$1"
    echo "Performing final theme package verification..."
    
    # Debug output
    echo "DEBUG: Verifying zip file: $zip_file"
    echo "DEBUG: Current directory: $(pwd)"
    
    # Validate zip exists
    if [[ ! -f "$zip_file" ]]; then
        echo -e "${RED}ERROR: Zip file not found: $zip_file${NC}"
        return 1
    fi
    
    # Create temp directory for verification
    local verify_dir="verify_theme_$(date +%s)"
    mkdir -p "$verify_dir"
    echo "DEBUG: Created temp directory: $verify_dir"
    
    # Extract and verify
    run_powershell "
        \$ErrorActionPreference = 'Stop'
        \$verifyDir = '$verify_dir'
        \$zipFile = '$zip_file'
        
        Write-Host 'DEBUG: PowerShell verification starting'
        Write-Host \"DEBUG: Verify dir: \$verifyDir\"
        Write-Host \"DEBUG: Zip file: \$zipFile\"
        Write-Host \"DEBUG: Current location: \$(Get-Location)\"
        
        try {
            # Extract zip
            Write-Host 'DEBUG: Extracting zip file...'
            Expand-Archive -Path \$zipFile -DestinationPath \$verifyDir -Force
            
            # Verify required files
            \$requiredFiles = @(
                'style.css',
                'index.php',
                'functions.php',
                'inc/theme-setup.php',
                'screenshot.png'
            )
            
            \$missingFiles = @()
            foreach (\$file in \$requiredFiles) {
                \$filePath = Join-Path \$verifyDir 'stay-n-alive' \$file
                if (-not (Test-Path \$filePath)) {
                    \$missingFiles += \$file
                }
            }
            
            if (\$missingFiles.Count -gt 0) {
                throw \"Missing required files in zip: \$(\$missingFiles -join ', ')\"
            }
            
            Write-Host 'DEBUG: All required files verified successfully'
        }
        catch {
            Write-Host \"ERROR: \$_\"
            exit 1
        }
        finally {
            if (Test-Path \$verifyDir) {
                Remove-Item -Path \$verifyDir -Recurse -Force
            }
        }
    " "Could not verify theme package"
    
    # Cleanup
    echo "DEBUG: Cleaning up temp directory"
    rm -rf "$verify_dir"
    return 0
}

# Description: Cleans up a directory and its contents
# Arguments:
#   $1 - Directory path to clean
# Returns: 0 on success, 1 on failure
# Dependencies: rm, PowerShell (on Windows)
# Example: cleanup_directory "dir-to-clean"
cleanup_directory() {
    local dir="$1"
    echo "Cleaning up directory: $dir"
    
    if [[ "$OSTYPE" == "msys" || "$OSTYPE" == "cygwin" ]]; then
        # Windows/Git Bash environment
        rm -rf "${dir}" 2>/dev/null || {
            # If rm fails, try Windows commands
            run_powershell "
                if (Test-Path '${dir}') {
                    Remove-Item -Path '${dir}' -Recurse -Force
                }
            " "Could not clean up directory"
        }
    else
        # Unix environment
        rm -rf "${dir}" 2>/dev/null || {
            echo -e "${RED}Warning: Could not remove directory ${dir}${NC}"
            return 1
        }
    fi
    return 0
}

# Description: Outputs debug state information about the theme directory
# Arguments:
#   $1 - Debug message to display
# Returns: None
# Dependencies: echo, find
# Example: debug_state "Before cleanup"
debug_state() {
    local msg="$1"
    echo "=== DEBUG: $msg ==="
    echo "Current directory: $(pwd)"
    echo "THEME_DIR: ${THEME_DIR}"
    echo "Directory structure:"
    if [ -d "${THEME_DIR}" ]; then
        find "${THEME_DIR}" -type d
        echo "File listing:"
        find "${THEME_DIR}" -type f
    else
        echo "Theme directory does not exist!"
    fi
    echo "==================="
}

# Description: Safely executes PowerShell commands with error handling
# Arguments:
#   $1 - PowerShell command to execute
#   $2 - Error message to display on failure (optional)
# Returns: 0 on success, 1 on failure
# Dependencies: powershell.exe
# Example: run_powershell "Write-Host 'Hello'" "Failed to write message"
run_powershell() {
    local command="$1"
    local error_msg="${2:-PowerShell command failed}"
    
    if ! command -v powershell.exe >/dev/null 2>&1; then
        echo -e "${RED}Error: PowerShell is not available${NC}"
        return 1
    }
    
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

# Description: Verifies all required commands are available
# Arguments: None
# Returns: 0 if all commands are available, 1 if any are missing
# Dependencies: command
# Example: check_required_commands
check_required_commands() {
    local required_commands=(
        "php"
        "cp"
        "mkdir"
        "grep"
        "find"
        "zip"
    )
    
    for cmd in "${required_commands[@]}"; do
        if ! command -v "$cmd" >/dev/null 2>&1; then
            echo -e "${RED}Error: Required command '$cmd' is not available${NC}"
            return 1
        fi
    done
    return 0
}

# Description: Creates a checkpoint file to track installation progress
# Arguments:
#   $1 - Stage name to checkpoint
# Returns: 0 on success
# Dependencies: date, echo
# Example: create_checkpoint "directories"
create_checkpoint() {
    local stage="$1"
    local timestamp=$(date +%Y%m%d_%H%M%S)
    local checkpoint_file="${THEME_DIR}/.checkpoint_${stage}_${timestamp}"
    
    echo "Creating checkpoint for stage: $stage"
    echo "Timestamp: $timestamp" > "$checkpoint_file"
    echo "Stage: $stage" >> "$checkpoint_file"
    
    return 0
}

# Description: Outputs debug information about file paths and contents
# Arguments:
#   $1 - Theme directory path to debug
# Returns: None
# Dependencies: ls, head, grep, find
# Example: debug_file_paths "/path/to/theme"
debug_file_paths() {
    if [[ -z "$1" ]]; then
        echo -e "${RED}Error: theme_dir argument is required${NC}"
        return 1
    }
    local theme_dir="$1"
    echo "Debugging file paths..."
    echo "Theme directory: ${theme_dir}"
    
    # Check theme-setup.php existence and permissions
    local setup_file="${theme_dir}/inc/theme-setup.php"
    echo "Checking theme-setup.php..."
    if [ -f "$setup_file" ]; then
        echo "File exists: $setup_file"
        ls -l "$setup_file"
        echo "File contents first 10 lines:"
        head -n 10 "$setup_file"
    else
        echo "ERROR: File not found: $setup_file"
        echo "Checking inc directory:"
        ls -la "${theme_dir}/inc/"
    fi
    
    # Verify directory structure
    echo "Directory structure:"
    find "${theme_dir}" -type d
    
    # List all PHP files
    echo "All PHP files:"
    find "${theme_dir}" -name "*.php" -type f -exec ls -l {} \;
    
    # Check functions.php require statement
    echo "Checking functions.php require statement:"
    grep -n "require.*theme-setup" "${theme_dir}/functions.php"
}

# Description: Verifies the contents of a theme zip file
# Arguments:
#   $1 - Path to zip file to verify
# Returns: 0 on success, 1 on failure
# Dependencies: PowerShell
# Example: verify_zip_contents "theme.zip"
verify_zip_contents() {
    if [[ -z "$1" ]]; then
        echo -e "${RED}Error: zip_file argument is required${NC}"
        return 1
    }
    local zip_file="$1"
    echo "Verifying zip contents..."
    
    # Create temp directory for zip verification
    local temp_dir="temp_verify_$(date +%s)"
    mkdir -p "$temp_dir"
    
    # Extract zip
    run_powershell "
        Expand-Archive -Path '$zip_file' -DestinationPath '$temp_dir' -Force
        
        Write-Host 'Zip contents:'
        Get-ChildItem -Path '$temp_dir' -Recurse | ForEach-Object { Write-Host \$_.FullName }
        
        if (Test-Path '$temp_dir/inc/theme-setup.php') {
            Write-Host 'theme-setup.php found in zip'
            Get-Content '$temp_dir/inc/theme-setup.php' | Select-Object -First 10
        } else {
            Write-Host 'ERROR: theme-setup.php not found in zip'
            Write-Host 'Contents of inc directory:'
            if (Test-Path '$temp_dir/inc') {
                Get-ChildItem '$temp_dir/inc'
            } else {
                Write-Host 'inc directory not found'
            }
        }
    " "Could not verify zip contents"
    
    # Cleanup
    rm -rf "$temp_dir"
}

# Description: Cleans up checkpoint files after successful completion
# Arguments: None
# Returns: 0 on success
# Dependencies: rm
# Example: cleanup_checkpoints
cleanup_checkpoints() {
    echo "Cleaning up checkpoint files..."
    find "${THEME_DIR}" -name ".checkpoint_*" -type f -delete
    return 0
}

# Only execute main at the end of the script
main