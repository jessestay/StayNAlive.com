#!/usr/bin/env bash

# Colors for output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}Creating Stay N Alive Theme...${NC}"

# Create necessary directories
mkdir -p {assets/{css,js},inc,languages,parts,patterns,styles,templates}

# Create style.css (required for WordPress themes)
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

# Create theme.json for block theme settings
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

# Create basic template files
cat > templates/index.html << 'EOL'
<!-- wp:template-part {"slug":"header","tagName":"header"} /-->
<!-- wp:group {"tagName":"main"} -->
<main class="wp-block-group">
    <!-- wp:post-content /-->
</main>
<!-- /wp:group -->
<!-- wp:template-part {"slug":"footer","tagName":"footer"} /-->
EOL

# Create template parts
cat > parts/header.html << 'EOL'
<!-- wp:group {"tagName":"header","className":"site-header"} -->
<header class="wp-block-group site-header">
    <!-- wp:site-title /-->
    <!-- wp:navigation /-->
</header>
<!-- /wp:group -->
EOL

cat > parts/footer.html << 'EOL'
<!-- wp:group {"tagName":"footer","className":"site-footer"} -->
<footer class="wp-block-group site-footer">
    <!-- wp:paragraph {"align":"center"} -->
    <p class="has-text-align-center">© 2024 Stay N Alive</p>
    <!-- /wp:paragraph -->
</footer>
<!-- /wp:group -->
EOL

# Create basic CSS
cat > assets/css/style.css << 'EOL'
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

# Create zip file
echo -e "${BLUE}Creating theme zip file...${NC}"
zip -r staynalive-theme.zip . -x ".*" -x "__MACOSX" -x "node_modules/*" -x "vendor/*" -x "*.git*" -x "*.log"

echo -e "${GREEN}Theme files created successfully!${NC}"
echo -e "Theme zip created at: ${BLUE}staynalive-theme.zip${NC}" 