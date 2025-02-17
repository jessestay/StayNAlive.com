#!/usr/bin/env bash

# Exit on error, undefined variables, and pipe failures
set -euo pipefail

# Colors for output
readonly GREEN='\033[0;32m'
readonly BLUE='\033[0;34m'
readonly NC='\033[0m'

# Theme directory name
readonly THEME_DIR="staynalive"

# Function to log messages
log() {
    echo -e "${BLUE}$1${NC}"
}

# Function to create directories
create_directories() {
    local -r dirs=(
        "assets/css"
        "assets/js"
        "inc"
        "languages"
        "parts"
        "patterns"
        "styles"
        "templates"
    )
    
    for dir in "${dirs[@]}"; do
        mkdir -p "${THEME_DIR}/${dir}"
    done
}

# Function to create style.css
create_style_css() {
    cat > "${THEME_DIR}/style.css" << 'EOL'
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
}

# Function to create theme.json
create_theme_json() {
    cat > "${THEME_DIR}/theme.json" << 'EOL'
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
}

# Function to create template files
create_templates() {
    cat > "${THEME_DIR}/templates/index.html" << 'EOL'
<!-- wp:template-part {"slug":"header","tagName":"header"} /-->
<!-- wp:group {"tagName":"main"} -->
<main class="wp-block-group">
    <!-- wp:post-content /-->
</main>
<!-- /wp:group -->
<!-- wp:template-part {"slug":"footer","tagName":"footer"} /-->
EOL
}

# Function to create template parts
create_template_parts() {
    # Header
    cat > "${THEME_DIR}/parts/header.html" << 'EOL'
<!-- wp:group {"tagName":"header","className":"site-header"} -->
<header class="wp-block-group site-header">
    <!-- wp:site-title /-->
    <!-- wp:navigation /-->
</header>
<!-- /wp:group -->
EOL

    # Footer
    cat > "${THEME_DIR}/parts/footer.html" << 'EOL'
<!-- wp:group {"tagName":"footer","className":"site-footer"} -->
<footer class="wp-block-group site-footer">
    <!-- wp:paragraph {"align":"center"} -->
    <p class="has-text-align-center">© 2024 Stay N Alive</p>
    <!-- /wp:paragraph -->
</footer>
<!-- /wp:group -->
EOL
}

# Function to create CSS files
create_css_files() {
    cat > "${THEME_DIR}/assets/css/style.css" << 'EOL'
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
}

# Function to create zip file
create_zip() {
    log "Creating theme zip file..."
    (cd "${THEME_DIR}" && zip -r ../staynalive-theme.zip .)
}

# Main execution
main() {
    log "Creating Stay N Alive Theme..."
    
    # Clean up any existing theme directory
    rm -rf "${THEME_DIR}"
    
    # Create fresh theme structure
    create_directories
    create_style_css
    create_theme_json
    create_templates
    create_template_parts
    create_css_files
    
    # Create zip file
    create_zip
    
    log "Theme files created successfully!"
    echo -e "Theme zip created at: ${BLUE}staynalive-theme.zip${NC}"
}

# Execute main function
main 