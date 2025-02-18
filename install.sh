#!/usr/bin/env bash

# Exit on error, undefined variables, and pipe failures
set -euo pipefail

# Colors for output
readonly GREEN='\033[0;32m'
readonly BLUE='\033[0;34m'
readonly RED='\033[0;31m'
readonly YELLOW='\033[1;33m'
readonly NC='\033[0m'

# Theme directory name
readonly THEME_DIR="stay-n-alive"

# Function to log messages
log() {
    echo -e "${BLUE}$1${NC}"
}

# Function to create directories
create_directories() {
    local -r dirs=(
        "assets/css/base"
        "assets/css/blocks"
        "assets/css/components"
        "assets/css/compatibility"
        "assets/css/utilities"
        "assets/js"
        "inc/classes"
        "languages"
        "parts"
        "patterns"
        "templates"
    )
    
    for dir in "${dirs[@]}"; do
        mkdir -p "${THEME_DIR}/${dir}" && echo "Created directory: ${dir}"
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
Description: A modern block-based WordPress theme.
Version: 1.0.0
License: GNU General Public License v2 or later
License URI: http://www.gnu.org/licenses/gpl-2.0.html
Text Domain: stay-n-alive
Tags: blog, custom-background, custom-colors, custom-logo, custom-menu, editor-style, featured-images, footer-widgets, full-width-template, rtl-language-support, sticky-post, theme-options, threaded-comments, translation-ready, block-styles, wide-blocks
*/

/* Basic theme styles */
body {
    font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, sans-serif;
    color: #333;
}
EOL

    # Verify the file was created correctly
    if ! grep -q "^Theme Name:" "${THEME_DIR}/style.css"; then
        echo -e "${RED}Error: Theme Name not found in style.css header${NC}"
        exit 1
    fi

    # Display the actual content for verification
    echo "Content of style.css:"
    cat "${THEME_DIR}/style.css"
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

# Function to create all templates
create_all_templates() {
    # Single template
    cat > "${THEME_DIR}/templates/single.html" << 'EOL'
<!-- wp:template-part {"slug":"header","tagName":"header"} /-->

<!-- wp:group {"tagName":"main","className":"site-main single-post"} -->
<main class="wp-block-group site-main single-post">
    <div id="post-<?php the_ID(); ?>" <?php post_class(); ?>>
        <!-- wp:post-featured-image {"align":"wide"} /-->

        <!-- wp:group {"className":"post-header"} -->
        <div class="wp-block-group post-header">
            <!-- wp:post-title {"level":1} /-->
            <!-- wp:post-meta /-->
        </div>
        <!-- /wp:group -->

        <!-- wp:post-content /-->
        <!-- wp:post-terms {"term":"post_tag"} /-->
        
        <?php wp_link_pages(); ?>
        
        <!-- wp:group {"className":"post-navigation"} -->
        <div class="wp-block-group post-navigation">
            <?php
            the_post_navigation(array(
                'prev_text' => __('Previous: %title', 'stay-n-alive'),
                'next_text' => __('Next: %title', 'stay-n-alive'),
            ));
            ?>
        </div>
        <!-- /wp:group -->

        <?php comments_template(); ?>
        
        <!-- wp:comments -->
        <div class="wp-block-comments">
            <?php
            wp_list_comments(array(
                'style' => 'ol',
                'avatar_size' => 60,
                'short_ping' => true,
            ));
            the_comments_pagination(array(
                'prev_text' => __('Previous', 'stay-n-alive'),
                'next_text' => __('Next', 'stay-n-alive'),
            ));
            ?>
        </div>
        <!-- /wp:comments -->
    </div>
</main>
<!-- /wp:group -->

<!-- wp:template-part {"slug":"footer","tagName":"footer"} /-->

<!-- wp:template-part {"slug":"index","tagName":"index"} /-->
EOL

    # Archive template
    cat > "${THEME_DIR}/templates/archive.html" << 'EOL'
<!-- wp:template-part {"slug":"header","tagName":"header"} /-->

<!-- wp:group {"tagName":"main","className":"site-main archive-page","layout":{"type":"constrained"}} -->
<main class="wp-block-group site-main archive-page">
    <!-- wp:group {"className":"archive-header","layout":{"type":"constrained"}} -->
    <div class="wp-block-group archive-header">
        <!-- wp:query-title {"type":"archive","textAlign":"center","fontSize":"x-large"} /-->
        <!-- wp:term-description {"textAlign":"center"} /-->
    </div>
    <!-- /wp:group -->

    <!-- wp:group {"className":"archive-content","layout":{"type":"constrained","contentSize":"1100px"}} -->
    <div class="wp-block-group archive-content">
        <!-- wp:columns {"className":"archive-layout"} -->
        <div class="wp-block-columns archive-layout">
            <!-- wp:column {"width":"70%"} -->
            <div class="wp-block-column" style="flex-basis:70%">
                <!-- wp:query -->
                <div class="wp-block-query">
                    <!-- wp:post-template -->
                        <!-- wp:group {"className":"post-item"} -->
                        <div class="wp-block-group post-item">
                            <!-- wp:post-featured-image {"isLink":true,"height":"300px"} /-->
                            <!-- wp:post-title {"isLink":true,"fontSize":"large"} /-->
                            <!-- wp:group {"className":"post-meta","layout":{"type":"flex","flexWrap":"wrap"}} -->
                            <div class="wp-block-group post-meta">
                                <!-- wp:post-date /-->
                                <!-- wp:post-author {"showAvatar":false} /-->
                                <!-- wp:post-terms {"term":"category"} /-->
                            </div>
                            <!-- /wp:group -->
                            <!-- wp:post-excerpt {"moreText":"Read More"} /-->
                        </div>
                        <!-- /wp:group -->
                    <!-- /wp:post-template -->

                    <!-- wp:query-pagination -->
                        <!-- wp:query-pagination-previous /-->
                        <!-- wp:query-pagination-numbers /-->
                        <!-- wp:query-pagination-next /-->
                    <!-- /wp:query-pagination -->

                    <!-- wp:query-pagination {"paginationArrow":"arrow"} -->
                    <div class="wp-block-query-pagination">
                        <?php
                        the_posts_pagination(array(
                            'mid_size' => 2,
                            'prev_text' => sprintf(
                                '%s <span class="nav-prev-text">%s</span>',
                                '←',
                                __('Newer posts', 'stay-n-alive')
                            ),
                            'next_text' => sprintf(
                                '<span class="nav-next-text">%s</span> %s',
                                __('Older posts', 'stay-n-alive'),
                                '→'
                            ),
                        ));
                        ?>
                    </div>
                    <!-- /wp:query-pagination -->
                </div>
                <!-- /wp:query -->
            </div>
            <!-- /wp:column -->

            <!-- wp:column {"width":"30%","className":"archive-sidebar"} -->
            <div class="wp-block-column archive-sidebar" style="flex-basis:30%">
                <!-- wp:pattern {"slug":"staynalive/sidebar-search"} /-->
                <!-- wp:pattern {"slug":"staynalive/sidebar-categories"} /-->
                <!-- wp:pattern {"slug":"staynalive/sidebar-recent-posts"} /-->
            </div>
            <!-- /wp:column -->
        </div>
        <!-- /wp:columns -->
    </div>
    <!-- /wp:group -->
</main>
<!-- /wp:group -->

<!-- wp:template-part {"slug":"footer","tagName":"footer"} /-->
EOL

    # 404 template
    cat > "${THEME_DIR}/templates/404.html" << 'EOL'
<!-- wp:template-part {"slug":"header","tagName":"header"} /-->

<!-- wp:group {"tagName":"main","className":"site-main error-404","layout":{"type":"constrained"}} -->
<main class="wp-block-group site-main error-404">
    <!-- wp:group {"className":"error-content","layout":{"type":"constrained","contentSize":"800px"}} -->
    <div class="wp-block-group error-content">
        <!-- wp:heading {"level":1,"className":"error-title","fontSize":"x-large"} -->
        <h1 class="error-title has-x-large-font-size">Oops! That page can't be found.</h1>
        <!-- /wp:heading -->

        <!-- wp:paragraph -->
        <p>It looks like nothing was found at this location. Maybe try a search or check out some recent posts?</p>
        <!-- /wp:paragraph -->

        <!-- wp:search {"label":"Search","buttonText":"Search","className":"error-search"} /-->

        <!-- wp:group {"className":"error-widgets","layout":{"type":"flex","flexWrap":"wrap","justifyContent":"space-between"}} -->
        <div class="wp-block-group error-widgets">
            <!-- wp:group {"className":"widget recent-posts"} -->
            <div class="wp-block-group widget recent-posts">
                <!-- wp:heading {"level":2,"fontSize":"large"} -->
                <h2 class="has-large-font-size">Recent Posts</h2>
                <!-- /wp:heading -->

                <!-- wp:latest-posts {"postsToShow":5,"displayPostDate":true} /-->
            </div>
            <!-- /wp:group -->

            <!-- wp:group {"className":"widget categories"} -->
            <div class="wp-block-group widget categories">
                <!-- wp:heading {"level":2,"fontSize":"large"} -->
                <h2 class="has-large-font-size">Categories</h2>
                <!-- /wp:heading -->

                <!-- wp:categories {"displayAsDropdown":false,"showHierarchy":true,"showPostCounts":true} /-->
            </div>
            <!-- /wp:group -->

            <!-- wp:group {"className":"widget tags"} -->
            <div class="wp-block-group widget tags">
                <!-- wp:heading {"level":2,"fontSize":"large"} -->
                <h2 class="has-large-font-size">Tags</h2>
                <!-- /wp:heading -->

                <!-- wp:tag-cloud {"numberOfTags":20} /-->
            </div>
            <!-- /wp:group -->
        </div>
        <!-- /wp:group -->
    </div>
    <!-- /wp:group -->
</main>
<!-- /wp:group -->

<!-- wp:template-part {"slug":"footer","tagName":"footer"} /-->
EOL

    # Link-in-bio template
    cat > "${THEME_DIR}/templates/link-bio.html" << 'EOL'
<!-- wp:template-part {"slug":"header","tagName":"header"} /-->

<!-- wp:cover {"url":"placeholder-hero.jpg","dimRatio":50,"minHeight":400,"align":"full","className":"bio-hero"} -->
<div class="wp-block-cover alignfull bio-hero">
    <span aria-hidden="true" class="wp-block-cover__background has-background-dim"></span>
    <div class="wp-block-cover__inner-container">
        <!-- wp:group {"className":"bio-header","layout":{"type":"constrained","contentSize":"800px"}} -->
        <div class="wp-block-group bio-header">
            <!-- wp:image {"className":"bio-avatar","width":150,"height":150,"scale":"cover","align":"center","style":{"border":{"radius":"100%"}}} -->
            <figure class="wp-block-image aligncenter bio-avatar">
                <img src="placeholder-avatar.jpg" alt="" style="border-radius:100%;width:150px;height:150px;object-fit:cover"/>
            </figure>
            <!-- /wp:image -->
            
            <!-- wp:heading {"textAlign":"center","level":1,"className":"bio-name"} -->
            <h1 class="wp-block-heading has-text-align-center bio-name">Your Name</h1>
            <!-- /wp:heading -->
            
            <!-- wp:paragraph {"align":"center","className":"bio-tagline"} -->
            <p class="has-text-align-center bio-tagline">Your brief tagline goes here</p>
            <!-- /wp:paragraph -->
        </div>
        <!-- /wp:group -->
    </div>
</div>
<!-- /wp:cover -->

<!-- wp:group {"className":"bio-links","layout":{"type":"constrained","contentSize":"600px"}} -->
<div class="wp-block-group bio-links">
    <!-- wp:pattern {"slug":"staynalive/bio-link-button"} /-->
</div>
<!-- /wp:group -->

<!-- wp:group {"className":"social-feed","layout":{"type":"constrained","contentSize":"1200px"}} -->
<div class="wp-block-group social-feed">
    <!-- wp:pattern {"slug":"staynalive/social-feed"} /-->
</div>
<!-- /wp:group -->

<!-- wp:template-part {"slug":"footer","tagName":"footer"} /-->
EOL

    # Search template
    cat > "${THEME_DIR}/templates/search.html" << 'EOL'
<!-- wp:template-part {"slug":"header","tagName":"header"} /-->

<!-- wp:group {"tagName":"main","className":"site-main search-results","layout":{"type":"constrained"}} -->
<main class="wp-block-group site-main search-results">
    <!-- wp:group {"className":"search-header","layout":{"type":"constrained"}} -->
    <div class="wp-block-group search-header">
        <!-- wp:search {"label":"Search","buttonText":"Search","className":"search-form"} /-->
        <!-- wp:query-title {"type":"search","textAlign":"center"} /-->
    </div>
    <!-- /wp:group -->

    <!-- wp:query {"queryId":1,"query":{"perPage":10,"offset":0,"postType":"post","order":"desc","orderBy":"date","search":"","inherit":true}} -->
    <div class="wp-block-query">
        <!-- wp:post-template -->
            <!-- wp:group {"className":"search-item"} -->
            <div class="wp-block-group search-item">
                <!-- wp:post-featured-image {"isLink":true,"width":"200px"} /-->
                <!-- wp:post-title {"isLink":true} /-->
                <!-- wp:post-excerpt /-->
            </div>
            <!-- /wp:group -->
        <!-- /wp:post-template -->

        <!-- wp:query-pagination -->
            <!-- wp:query-pagination-previous /-->
            <!-- wp:query-pagination-numbers /-->
            <!-- wp:query-pagination-next /-->
        <!-- /wp:query-pagination -->

        <!-- wp:query-no-results -->
            <!-- wp:paragraph {"className":"no-results"} -->
            <p class="no-results">No results found. Try a different search.</p>
            <!-- /wp:paragraph -->
        <!-- /wp:query-no-results -->
    </div>
    <!-- /wp:query -->
</main>
<!-- /wp:group -->

<!-- wp:template-part {"slug":"footer","tagName":"footer"} /-->
EOL

    # Category template
    cat > "${THEME_DIR}/templates/category.html" << 'EOL'
<!-- wp:template-part {"slug":"header","tagName":"header"} /-->

<!-- wp:group {"tagName":"main","className":"site-main category-archive","layout":{"type":"constrained"}} -->
<main class="wp-block-group site-main category-archive">
    <!-- wp:group {"className":"category-header","layout":{"type":"constrained"}} -->
    <div class="wp-block-group category-header">
        <!-- wp:query-title {"type":"archive","textAlign":"center"} /-->
        <!-- wp:term-description {"textAlign":"center"} /-->
    </div>
    <!-- /wp:group -->

    <!-- wp:columns -->
    <div class="wp-block-columns">
        <!-- wp:column {"width":"70%"} -->
        <div class="wp-block-column" style="flex-basis:70%">
            <!-- wp:query -->
            <div class="wp-block-query">
                <!-- wp:post-template -->
                    <!-- wp:group {"className":"category-item"} -->
                    <div class="wp-block-group category-item">
                        <!-- wp:post-featured-image {"isLink":true} /-->
                        <!-- wp:post-title {"isLink":true} /-->
                        <!-- wp:post-excerpt /-->
                    </div>
                    <!-- /wp:group -->
                <!-- /wp:post-template -->

                <!-- wp:query-pagination -->
                    <!-- wp:query-pagination-previous /-->
                    <!-- wp:query-pagination-numbers /-->
                    <!-- wp:query-pagination-next /-->
                <!-- /wp:query-pagination -->
            </div>
            <!-- /wp:query -->
        </div>
        <!-- /wp:column -->

        <!-- wp:column {"width":"30%"} -->
        <div class="wp-block-column" style="flex-basis:30%">
            <!-- wp:pattern {"slug":"staynalive/sidebar-categories"} /-->
            <!-- wp:pattern {"slug":"staynalive/sidebar-recent-posts"} /-->
        </div>
        <!-- /wp:column -->
    </div>
    <!-- /wp:columns -->
</main>
<!-- /wp:group -->

<!-- wp:template-part {"slug":"footer","tagName":"footer"} /-->
EOL

    # Tag Archive template
    cat > "${THEME_DIR}/templates/tag.html" << 'EOL'
<!-- wp:template-part {"slug":"header","tagName":"header"} /-->

<!-- wp:group {"tagName":"main","className":"site-main tag-archive","layout":{"type":"constrained"}} -->
<main class="wp-block-group site-main tag-archive">
    <!-- wp:query-title {"type":"archive","textAlign":"center"} /-->
    
    <!-- wp:columns -->
    <div class="wp-block-columns">
        <!-- wp:column {"width":"70%"} -->
        <div class="wp-block-column" style="flex-basis:70%">
            <!-- wp:query -->
            <div class="wp-block-query">
                <!-- wp:post-template -->
                    <!-- wp:group {"className":"tag-item"} -->
                    <div class="wp-block-group tag-item">
                        <!-- wp:post-featured-image {"isLink":true} /-->
                        <!-- wp:post-title {"isLink":true} /-->
                        <!-- wp:post-excerpt /-->
                    </div>
                    <!-- /wp:group -->
                <!-- /wp:post-template -->

                <!-- wp:query-pagination -->
                    <!-- wp:query-pagination-previous /-->
                    <!-- wp:query-pagination-numbers /-->
                    <!-- wp:query-pagination-next /-->
                <!-- /wp:query-pagination -->
            </div>
            <!-- /wp:query -->
        </div>
        <!-- /wp:column -->

        <!-- wp:column {"width":"30%"} -->
        <div class="wp-block-column" style="flex-basis:30%">
            <!-- wp:pattern {"slug":"staynalive/sidebar-tags"} /-->
            <!-- wp:pattern {"slug":"staynalive/sidebar-recent-posts"} /-->
        </div>
        <!-- /wp:column -->
    </div>
    <!-- /wp:columns -->
</main>
<!-- /wp:group -->

<!-- wp:template-part {"slug":"footer","tagName":"footer"} /-->
EOL

    # Author Archive template
    cat > "${THEME_DIR}/templates/author.html" << 'EOL'
<!-- wp:template-part {"slug":"header","tagName":"header"} /-->

<!-- wp:group {"tagName":"main","className":"site-main author-archive","layout":{"type":"constrained"}} -->
<main class="wp-block-group site-main author-archive">
    <!-- wp:pattern {"slug":"staynalive/author-bio"} /-->
    
    <!-- wp:query {"queryId":1,"query":{"perPage":10,"offset":0,"postType":"post","order":"desc","orderBy":"date","author":"","inherit":true}} -->
    <div class="wp-block-query">
        <!-- wp:post-template -->
            <!-- wp:group {"className":"author-post-item"} -->
            <div class="wp-block-group author-post-item">
                <!-- wp:post-featured-image {"isLink":true} /-->
                <!-- wp:post-title {"isLink":true} /-->
                <!-- wp:post-excerpt /-->
            </div>
            <!-- /wp:group -->
        <!-- /wp:post-template -->

        <!-- wp:query-pagination -->
            <!-- wp:query-pagination-previous /-->
            <!-- wp:query-pagination-numbers /-->
            <!-- wp:query-pagination-next /-->
        <!-- /wp:query-pagination -->
    </div>
    <!-- /wp:query -->
</main>
<!-- /wp:group -->

<!-- wp:template-part {"slug":"footer","tagName":"footer"} /-->
EOL

    # Index template
    cat > "${THEME_DIR}/templates/index.html" << 'EOL'
<!-- wp:template-part {"slug":"header","tagName":"header"} /-->

<!-- wp:group {"tagName":"main","className":"site-main index-page","layout":{"type":"constrained"}} -->
<main class="wp-block-group site-main index-page">
    <!-- wp:query -->
    <div class="wp-block-query">
        <!-- wp:post-template -->
            <!-- wp:group {"className":"post-item"} -->
            <div class="wp-block-group post-item">
                <!-- wp:post-featured-image {"isLink":true,"align":"wide"} /-->
                <!-- wp:post-title {"isLink":true,"fontSize":"large"} /-->
                <!-- wp:group {"className":"post-meta","layout":{"type":"flex","flexWrap":"wrap"}} -->
                <div class="wp-block-group post-meta">
                    <!-- wp:post-date /-->
                    <!-- wp:post-author {"showAvatar":false} /-->
                    <!-- wp:post-terms {"term":"category"} /-->
                </div>
                <!-- /wp:group -->
                <!-- wp:post-excerpt {"moreText":"Read More"} /-->
            </div>
            <!-- /wp:group -->
        <!-- /wp:post-template -->

        <!-- wp:query-pagination -->
            <!-- wp:query-pagination-previous /-->
            <!-- wp:query-pagination-numbers /-->
            <!-- wp:query-pagination-next /-->
        <!-- /wp:query-pagination -->
    </div>
    <!-- /wp:query -->
</main>
<!-- /wp:group -->

<!-- wp:template-part {"slug":"footer","tagName":"footer"} /-->
EOL
}

# Function to create template parts
create_template_parts() {
    # Header with all original functionality
    cat > "${THEME_DIR}/parts/header.html" << 'EOL'
<!DOCTYPE html>
<html <?php language_attributes(); ?>>
<head>
    <meta charset="<?php bloginfo('charset'); ?>">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <?php wp_head(); ?>
</head>
<body <?php body_class(); ?>>
<?php wp_body_open(); ?>

<!-- wp:group {"tagName":"header","className":"site-header"} -->
<header class="wp-block-group site-header">
    <!-- wp:site-title /-->
    <?php
    wp_nav_menu(array(
        'theme_location' => 'primary',
        'menu_class' => 'primary-navigation',
        'container' => 'nav',
        'container_class' => 'main-navigation',
    ));
    ?>
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
<?php wp_footer(); ?>
</body>
</html>
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

    # Add to create_css_files function
    cat > "${THEME_DIR}/assets/css/base/wordpress.css" << 'EOL'
.wp-caption {
    max-width: 100%;
    margin-bottom: 1.5em;
}

.wp-caption-text {
    font-style: italic;
    text-align: center;
}

.sticky {
    display: block;
    background: #f7f7f7;
    padding: 1em;
}

.gallery-caption {
    display: block;
}

.bypostauthor {
    background: #f7f7f7;
    padding: 1em;
}

.alignright {
    float: right;
    margin: 0 0 1em 1em;
}

.alignleft {
    float: left;
    margin: 0 1em 1em 0;
}

.aligncenter {
    display: block;
    margin: 1em auto;
}

.screen-reader-text {
    clip: rect(1px, 1px, 1px, 1px);
    position: absolute !important;
    height: 1px;
    width: 1px;
    overflow: hidden;
}

.gallery {
    margin-bottom: 1.5em;
    display: grid;
    grid-gap: 1.5em;
}

.gallery-item {
    display: inline-block;
    text-align: center;
    width: 100%;
}

.gallery-columns-2 {
    grid-template-columns: repeat(2, 1fr);
}

.gallery-columns-3 {
    grid-template-columns: repeat(3, 1fr);
}

.gallery-columns-4 {
    grid-template-columns: repeat(4, 1fr);
}

.gallery-columns-5 {
    grid-template-columns: repeat(5, 1fr);
}

.gallery-columns-6 {
    grid-template-columns: repeat(6, 1fr);
}

.gallery-columns-7 {
    grid-template-columns: repeat(7, 1fr);
}

.gallery-columns-8 {
    grid-template-columns: repeat(8, 1fr);
}

.gallery-columns-9 {
    grid-template-columns: repeat(9, 1fr);
}
EOL

    # Add to create_css_files function
    cat > "${THEME_DIR}/assets/css/editor-style.css" << 'EOL'
/* Editor Styles */
.editor-styles-wrapper {
    font-family: var(--wp--preset--font-family--primary);
    color: var(--color-text);
}

.editor-post-title__input {
    font-family: var(--wp--preset--font-family--primary);
    font-size: 2.5em;
    font-weight: bold;
}

.wp-block {
    max-width: 840px;
}

.wp-block[data-align="wide"] {
    max-width: 1100px;
}

.wp-block[data-align="full"] {
    max-width: none;
}
EOL
}

# Function to create all CSS files
create_all_css_files() {
    # Base CSS
    cat > "${THEME_DIR}/assets/css/base/base.css" << 'EOL'
:root {
    --color-primary: #1e73be;
    --color-secondary: #666666;
    --color-dark: #333333;
    --color-light: #f5f5f5;
    --color-white: #ffffff;
    --color-border: #e5e5e5;
    --color-muted: #666;
    
    --spacing-xs: 5px;
    --spacing-sm: 10px;
    --spacing-md: 20px;
    --spacing-lg: 40px;
    --spacing-xl: 80px;
    
    --radius-sm: 4px;
    --radius-md: 8px;
    --radius-lg: 16px;
}

body {
    margin: 0;
    font-family: var(--wp--preset--font-family--primary);
    color: var(--color-text);
    background: var(--color-background);
    line-height: 1.6;
}
EOL

    # Header CSS
    cat > "${THEME_DIR}/assets/css/components/header.css" << 'EOL'
.site-header {
    background: var(--wp--preset--color--white);
    box-shadow: 0 2px 4px rgba(0,0,0,0.05);
    position: sticky;
    top: 0;
    z-index: 1000;
}

.header-content {
    padding: 20px 0;
}

.site-branding {
    gap: 15px;
    align-items: center;
}

.site-title {
    margin: 0;
}

.primary-navigation {
    gap: 30px;
}

.primary-navigation a {
    color: var(--wp--preset--color--dark);
    text-decoration: none;
    font-weight: 500;
    padding: 5px 0;
    position: relative;
}

.primary-navigation a::after {
    content: '';
    position: absolute;
    bottom: 0;
    left: 0;
    width: 100%;
    height: 2px;
    background: var(--wp--preset--color--primary);
    transform: scaleX(0);
    transition: transform 0.3s ease;
}

.primary-navigation a:hover::after,
.primary-navigation .current-menu-item a::after {
    transform: scaleX(1);
}

@media (max-width: 768px) {
    .header-content {
        flex-direction: column;
        gap: 20px;
    }
    
    .primary-navigation {
        width: 100%;
        justify-content: center;
    }
}
EOL

    # Link Bio CSS
    cat > "${THEME_DIR}/assets/css/components/link-bio.css" << 'EOL'
.link-bio-page {
    padding: var(--spacing-lg) var(--spacing-md);
    background: var(--color-background);
}

.bio-header {
    margin-bottom: var(--spacing-lg);
    text-align: center;
}

.bio-avatar {
    margin-bottom: var(--spacing-md);
}

.bio-avatar img {
    box-shadow: 0 4px 12px rgba(0,0,0,0.1);
}

.bio-name {
    margin-bottom: var(--spacing-sm);
    color: var(--color-primary);
}

.bio-description {
    color: var(--color-muted);
    font-size: 1.1em;
}

.bio-links {
    margin-bottom: var(--spacing-lg);
}

.bio-link-button {
    margin-bottom: var(--spacing-sm);
}

.bio-link-button .wp-block-button__link {
    width: 100%;
    text-align: center;
    padding: var(--spacing-md);
    border-radius: var(--radius-md);
    transition: transform 0.2s, box-shadow 0.2s;
}

.bio-link-button .wp-block-button__link:hover {
    transform: translateY(-2px);
    box-shadow: 0 4px 8px rgba(0,0,0,0.1);
}

/* Button Style Variations */
.bio-link-button .is-style-gradient .wp-block-button__link {
    background: linear-gradient(135deg, var(--color-primary), var(--color-accent));
    border: none;
    color: var(--color-background);
}

.bio-link-button .is-style-glass .wp-block-button__link {
    background: rgba(255, 255, 255, 0.1);
    -webkit-backdrop-filter: blur(10px);
    backdrop-filter: blur(10px);
    border: 1px solid rgba(255, 255, 255, 0.2);
}

.bio-link-button .is-style-neon .wp-block-button__link {
    background: transparent;
    border: 2px solid var(--color-primary);
    box-shadow: 0 0 15px var(--color-primary);
    text-shadow: 0 0 5px var(--color-primary);
}
EOL

    # Social Feed CSS
    cat > "${THEME_DIR}/assets/css/components/social-feed.css" << 'EOL'
.social-feed-container {
    margin-top: var(--spacing-xl);
}

.social-feed-tabs {
    margin-bottom: var(--spacing-lg);
    gap: var(--spacing-md);
}

.social-tab {
    padding: var(--spacing-sm) var(--spacing-md);
    border: none;
    background: transparent;
    color: var(--color-muted);
    cursor: pointer;
    font-weight: 500;
    position: relative;
    transition: color 0.3s ease;
}

.social-tab::after {
    content: '';
    position: absolute;
    bottom: -2px;
    left: 0;
    width: 100%;
    height: 2px;
    background: var(--color-primary);
    transform: scaleX(0);
    transition: transform 0.3s ease;
}

.social-tab.active {
    color: var(--color-primary);
}

.social-tab.active::after {
    transform: scaleX(1);
}

.social-feed-grid {
    display: grid;
    grid-template-columns: repeat(auto-fill, minmax(300px, 1fr));
    gap: var(--spacing-md);
}

.social-card {
    background: var(--color-background);
    border-radius: var(--radius-md);
    overflow: hidden;
    box-shadow: 0 2px 4px rgba(0,0,0,0.1);
    transition: transform 0.3s ease, box-shadow 0.3s ease;
}

.social-card:hover {
    transform: translateY(-5px);
    box-shadow: 0 8px 16px rgba(0,0,0,0.1);
}
EOL

    # Footer CSS
    cat > "${THEME_DIR}/assets/css/components/footer.css" << 'EOL'
.footer-widgets {
    background-color: #2b2b2b;
    padding: 6% 0;
    color: #fff;
}

.footer-widget {
    float: left;
    color: #fff;
}

.footer-bottom {
    background-color: rgba(0,0,0,0.32);
    padding: 15px 0;
}

.et-social-icons {
    float: right;
}

.et-social-icons li {
    display: inline-block;
    margin-left: 20px;
}
EOL
}

# Function to create JavaScript files
create_all_js_files() {
    # Social Feed JS
    cat > "${THEME_DIR}/assets/js/social-feed.js" << 'EOL'
class SocialFeed {
    constructor() {
        this.currentFeed = 'instagram';
        this.feeds = {
            instagram: [],
            tiktok: [],
            youtube: [],
            twitter: []
        };
        this.init();
    }

    async init() {
        this.container = document.querySelector('.social-feed-grid');
        this.tabs = document.querySelectorAll('.social-tab');
        
        this.tabs.forEach(tab => {
            tab.addEventListener('click', () => this.switchFeed(tab.dataset.feed));
        });
        
        await this.loadFeeds();
    }

    async loadFeeds() {
        try {
            const endpoints = {
                instagram: '/wp-json/staynalive/v1/instagram-feed',
                tiktok: '/wp-json/staynalive/v1/tiktok-feed',
                youtube: '/wp-json/staynalive/v1/youtube-feed',
                twitter: '/wp-json/staynalive/v1/twitter-feed'
            };

            const responses = await Promise.all(
                Object.entries(endpoints).map(async ([platform, endpoint]) => {
                    const response = await fetch(endpoint);
                    const data = await response.json();
                    return [platform, data];
                })
            );

            responses.forEach(([platform, data]) => {
                this.feeds[platform] = data;
            });

            this.renderFeed(this.currentFeed);
        } catch (_error) {
            console.error('Failed to fetch social feed');
            this.handleError();
        }
    }

    renderFeed(type) {
        const feed = this.feeds[type];
        this.container.innerHTML = '';
        
        feed.forEach(item => {
            const card = this.createCard(item, type);
            this.container.appendChild(card);
            this.animateCard(card);
        });
    }

    createCard(item, type) {
        const card = document.createElement('div');
        card.className = 'social-card';
        card.innerHTML = type === 'instagram' ? 
            this.renderInstagramItem(item) : 
            this.renderTikTokItem(item);
        return card;
    }

    animateCard(card) {
        card.style.opacity = '0';
        card.style.transform = 'translateY(20px)';
        
        setTimeout(() => {
            card.style.transition = 'opacity 0.5s ease, transform 0.5s ease';
            card.style.opacity = '1';
            card.style.transform = 'translateY(0)';
        }, 100);
    }
}

document.addEventListener('DOMContentLoaded', () => new SocialFeed());
EOL

    # Animations JS
    cat > "${THEME_DIR}/assets/js/animations.js" << 'EOL'
document.addEventListener('DOMContentLoaded', () => {
    const observerOptions = {
        root: null,
        rootMargin: '0px',
        threshold: 0.1
    };

    const observer = new IntersectionObserver((entries) => {
        entries.forEach(entry => {
            if (entry.isIntersecting) {
                entry.target.classList.add('animate-in');
                observer.unobserve(entry.target);
            }
        });
    }, observerOptions);

    document.querySelectorAll('.animate-on-scroll').forEach(element => {
        observer.observe(element);
    });
});
EOL
}

# Function to create block patterns
create_block_patterns() {
    mkdir -p "${THEME_DIR}/patterns"
    
    # Bio Link Button Pattern
    cat > "${THEME_DIR}/patterns/bio-link-button.html" << 'EOL'
<!-- wp:group {"className":"bio-link-button","layout":{"type":"constrained"}} -->
<div class="wp-block-group bio-link-button">
    <!-- wp:buttons {"layout":{"type":"flex","orientation":"vertical","justifyContent":"center"}} -->
    <div class="wp-block-buttons">
        <!-- wp:button {"width":100,"className":"is-style-fill"} -->
        <div class="wp-block-button has-custom-width wp-block-button__width-100">
            <a class="wp-block-button__link" href="#">Link Button</a>
        </div>
        <!-- /wp:button -->
    </div>
    <!-- /wp:buttons -->
</div>
<!-- /wp:group -->
EOL

    # Social Grid Pattern
    cat > "${THEME_DIR}/patterns/social-grid.html" << 'EOL'
<!-- wp:group {"className":"social-grid","layout":{"type":"constrained"}} -->
<div class="wp-block-group social-grid">
    <!-- wp:columns {"className":"social-grid-row"} -->
    <div class="wp-block-columns social-grid-row">
        <!-- wp:column -->
        <div class="wp-block-column">
            <!-- wp:group {"className":"social-card"} -->
            <div class="wp-block-group social-card">
                <!-- wp:image {"className":"social-media-embed"} -->
                <figure class="wp-block-image social-media-embed">
                    <img src="placeholder.jpg" alt=""/>
                </figure>
                <!-- /wp:image -->
                
                <!-- wp:paragraph {"className":"social-caption"} -->
                <p class="social-caption">Caption text here</p>
                <!-- /wp:paragraph -->
                
                <!-- wp:buttons {"className":"social-actions"} -->
                <div class="wp-block-buttons social-actions">
                    <!-- wp:button {"className":"is-style-outline"} -->
                    <div class="wp-block-button">
                        <a class="wp-block-button__link is-style-outline" href="#">View Post</a>
                    </div>
                    <!-- /wp:button -->
                </div>
                <!-- /wp:buttons -->
            </div>
            <!-- /wp:group -->
        </div>
        <!-- /wp:column -->
    </div>
    <!-- /wp:columns -->
</div>
<!-- /wp:group -->
EOL
}

# Function to create additional patterns
create_additional_patterns() {
    # Author Bio Pattern
    cat > "${THEME_DIR}/patterns/author-bio.html" << 'EOL'
<!-- wp:group {"className":"author-bio-section","layout":{"type":"constrained"}} -->
<div class="wp-block-group author-bio-section">
    <!-- wp:columns {"verticalAlignment":"center"} -->
    <div class="wp-block-columns are-vertically-aligned-center">
        <!-- wp:column {"width":"30%"} -->
        <div class="wp-block-column" style="flex-basis:30%">
            <!-- wp:image {"className":"author-image","width":200,"height":200,"scale":"cover","style":{"border":{"radius":"100%"}}} -->
            <figure class="wp-block-image author-image">
                <img src="placeholder-author.jpg" alt="" style="border-radius:100%;width:200px;height:200px;object-fit:cover"/>
            </figure>
            <!-- /wp:image -->
        </div>
        <!-- /wp:column -->

        <!-- wp:column {"width":"70%"} -->
        <div class="wp-block-column" style="flex-basis:70%">
            <!-- wp:heading {"level":2,"className":"author-name"} -->
            <h2 class="author-name">Jesse Stay</h2>
            <!-- /wp:heading -->
            
            <!-- wp:paragraph {"className":"author-bio"} -->
            <p class="author-bio">Author bio content goes here...</p>
            <!-- /wp:paragraph -->
            
            <!-- wp:social-links {"className":"author-social"} -->
            <ul class="wp-block-social-links author-social">
                <!-- wp:social-link {"url":"https://twitter.com/jesse","service":"twitter"} /-->
                <!-- wp:social-link {"url":"https://linkedin.com/in/jessestay","service":"linkedin"} /-->
            </ul>
            <!-- /wp:social-links -->
        </div>
        <!-- /wp:column -->
    </div>
    <!-- /wp:columns -->
</div>
<!-- /wp:group -->
EOL
}

# Function to create additional CSS files
create_additional_css() {
    # Animations CSS
    cat > "${THEME_DIR}/assets/css/utilities/animations.css" << 'EOL'
@keyframes floatIn {
    0% { transform: translateY(-20px); opacity: 0; }
    100% { transform: translateY(0); opacity: 1; }
}

@keyframes pulseScale {
    0% { transform: scale(1); }
    50% { transform: scale(1.05); }
    100% { transform: scale(1); }
}

@keyframes shimmer {
    0% { background-position: -200% 0; }
    100% { background-position: 200% 0; }
}

.animate-float-in {
    animation: floatIn 0.8s cubic-bezier(0.4, 0, 0.2, 1) forwards;
}

.animate-pulse {
    animation: pulseScale 2s ease-in-out infinite;
}

.shimmer-effect {
    background: linear-gradient(
        90deg,
        transparent 0%,
        rgba(255, 255, 255, 0.2) 50%,
        transparent 100%
    );
    background-size: 200% 100%;
    animation: shimmer 1.5s infinite;
}

@media (prefers-reduced-motion: reduce) {
    .animate-float-in,
    .animate-pulse,
    .shimmer-effect {
        animation: none;
    }
}
EOL

    # Author Bio CSS
    cat > "${THEME_DIR}/assets/css/components/author-bio.css" << 'EOL'
.author-bio-section {
    padding: var(--spacing-xl) var(--spacing-md);
    background: var(--color-light);
    border-radius: var(--radius-lg);
}

.author-image {
    margin: 0 auto;
    box-shadow: 0 8px 24px rgba(0,0,0,0.1);
    transition: transform 0.3s ease;
}

.author-image:hover {
    transform: scale(1.05);
}

.author-name {
    color: var(--color-primary);
    margin-bottom: var(--spacing-md);
    font-size: 2em;
}

.author-bio {
    color: var(--color-secondary);
    font-size: 1.1em;
    line-height: 1.8;
    margin-bottom: var(--spacing-lg);
}

.author-social {
    gap: var(--spacing-md);
}

@media (max-width: 768px) {
    .author-bio-section {
        padding: var(--spacing-lg) var(--spacing-md);
    }
    
    .author-image {
        margin-bottom: var(--spacing-md);
    }
}
EOL

    # Divi Compatibility CSS
    cat > "${THEME_DIR}/assets/css/compatibility/divi.css" << 'EOL'
.et_pb_scroll_top {
    position: fixed;
    right: 20px;
    bottom: 20px;
    background: rgba(0,0,0,0.4);
    padding: 10px;
    border-radius: 4px;
    color: #fff;
    cursor: pointer;
    display: none;
    z-index: 9999;
}

.et_pb_scroll_top.et-visible {
    display: block;
    animation: fadeIn 0.4s ease-in-out;
}

.et-social-icons {
    float: right;
}

.et-social-icons li {
    display: inline-block;
    margin-left: 20px;
}

.et_pb_section {
    padding: 4% 0;
}
EOL

    # Mobile Menu CSS
    cat > "${THEME_DIR}/assets/css/components/mobile-menu.css" << 'EOL'
@media (max-width: 980px) {
    .et_mobile_menu {
        display: none;
        position: absolute;
        top: 100%;
        left: 0;
        width: 100%;
        background: #fff;
        border-top: 3px solid #2ea3f2;
        padding: 5%;
        box-shadow: 0 2px 5px rgba(0,0,0,0.1);
    }

    .et_mobile_menu.nav-open {
        display: block;
    }

    .mobile_nav.opened .mobile_menu_bar:before {
        content: "M";
    }
}
EOL

    # Normalize CSS
    cat > "${THEME_DIR}/assets/css/base/normalize.css" << 'EOL'
/*! normalize.css v8.0.1 */
html{line-height:1.15;-webkit-text-size-adjust:100%}
body{margin:0}
main{display:block}
h1{font-size:2em;margin:.67em 0}
hr{box-sizing:content-box;height:0;overflow:visible}
pre{font-family:monospace,monospace;font-size:1em}
a{background-color:transparent}
abbr[title]{border-bottom:none;text-decoration:underline;text-decoration:underline dotted}
b,strong{font-weight:bolder}
code,kbd,samp{font-family:monospace,monospace;font-size:1em}
small{font-size:80%}
sub,sup{font-size:75%;line-height:0;position:relative;vertical-align:baseline}
sub{bottom:-.25em}
sup{top:-.5em}
img{border-style:none}
button,input,optgroup,select,textarea{font-family:inherit;font-size:100%;line-height:1.15;margin:0}
button,input{overflow:visible}
button,select{text-transform:none}
[type=button],[type=reset],[type=submit],button{-webkit-appearance:button}
[type=button]::-moz-focus-inner,[type=reset]::-moz-focus-inner,[type=submit]::-moz-focus-inner,button:-moz-focus-inner{border-style:none;padding:0}
[type=button]:-moz-focusring,[type=reset]:-moz-focusring,[type=submit]:-moz-focus-ring{outline:1px dotted ButtonText}
fieldset{padding:.35em .75em .625em}
legend{box-sizing:border-box;color:inherit;display:table;max-width:100%;padding:0;white-space:normal}
progress{vertical-align:baseline}
textarea{overflow:auto}
[type=checkbox],[type=radio]{box-sizing:border-box;padding:0}
[type=number]::-webkit-inner-spin-button,[type=number]::-webkit-outer-spin-button{height:auto}
[type=search]{-webkit-appearance:textfield;outline-offset:-2px}
[type=search]::-webkit-search-decoration{-webkit-appearance:none}
::-webkit-file-upload-button{-webkit-appearance:button;font:inherit}
details{display:block}
summary{display:list-item}
template{display:none}
[hidden]{display:none}
EOL

    # Original Divi Theme Compatibility
    cat > "${THEME_DIR}/assets/css/compatibility/divi-legacy.css" << 'EOL'
.et_pb_section {
    position: relative;
    background-color: #fff;
}

.et_pb_row {
    position: relative;
    width: 80%;
    max-width: 1080px;
    margin: auto;
}

.et_pb_column {
    float: left;
    position: relative;
    z-index: 9;
    background-position: center;
    background-size: cover;
}

.et_pb_module {
    position: relative;
}

.et_pb_text {
    word-wrap: break-word;
}

.et_pb_button {
    font-size: 20px;
    font-weight: 500;
    padding: .3em 1em;
    line-height: 1.7em!important;
    background-color: transparent;
    background-size: cover;
    background-position: 50%;
    background-repeat: no-repeat;
    border: 2px solid;
    border-radius: 3px;
    transition: all .2s;
}
EOL
}

# Function to create additional JavaScript files
create_additional_js() {
    # ShareThis Integration
    cat > "${THEME_DIR}/assets/js/sharethis.js" << 'EOL'
!function(f,b,e,v,n,t,s) {
    if(f.fbq)return;n=f.fbq=function(){n.callMethod?
    n.callMethod.apply(n,arguments):n.queue.push(arguments)};
    if(!f._fbq)f._fbq=n;n.push=n;n.loaded=!0;n.version='2.0';
    n.queue=[];t=b.createElement(e);t.async=!0;
    t.src=v;s=b.getElementsByTagName(e)[0];
    s.parentNode.insertBefore(t,s)
}(window, document,'script','https://connect.facebook.net/en_US/fbevents.js');

fbq('init', '341523889516787');
fbq('track', "PageView");
EOL

    # Custom Emoji Handling
    cat > "${THEME_DIR}/assets/js/emoji.js" << 'EOL'
window._wpemojiSettings = {
    "baseUrl": "https://s.w.org/images/core/emoji/12.0.0-1/72x72/",
    "ext": ".png",
    "svgUrl": "https://s.w.org/images/core/emoji/12.0.0-1/svg/",
    "svgExt": ".svg",
    "source": {
        "concatemoji": "/wp-includes/js/wp-emoji-release.min.js"
    }
};
EOL

    # Google Maps Integration
    cat > "${THEME_DIR}/assets/js/google-maps.js" << 'EOL'
// Google Maps Widget Integration
function initGoogleMapsWidget() {
    const mapElements = document.querySelectorAll('.gmw-map');
    const apiKey = 'AIzaSyB5UXGleTjfdmWGLizMER67FQcX_nyDzQ4';  // From original site
    
    mapElements.forEach(element => {
        const location = element.dataset.location;
        const zoom = element.dataset.zoom || 14;
        const iframe = document.createElement('iframe');
        
        iframe.src = `https://www.google.com/maps/embed/v1/place?key=${apiKey}&q=${encodeURIComponent(location)}&zoom=${zoom}`;
        iframe.width = '100%';
        iframe.height = element.dataset.height || '300';
        iframe.style.border = '0';
        iframe.allowFullscreen = true;
        
        element.appendChild(iframe);
    });
}

document.addEventListener('DOMContentLoaded', initGoogleMapsWidget);
EOL

    # Enhanced Emoji Support
    cat > "${THEME_DIR}/assets/js/emoji-support.js" << 'EOL'
// From original header.php
window._wpemojiSettings = {
    "baseUrl": "https://s.w.org/images/core/emoji/12.0.0-1/72x72/",
    "ext": ".png",
    "svgUrl": "https://s.w.org/images/core/emoji/12.0.0-1/svg/",
    "svgExt": ".svg",
    "source": {
        "concatemoji": "/wp-includes/js/wp-emoji-release.min.js"
    }
};

// Enhanced emoji handling
!function(e,a,t){var r,n,o,i,p=a.createElement("canvas"),s=p.getContext&&p.getContext("2d");function c(e,t){var a=String.fromCharCode;s.clearRect(0,0,p.width,p.height),s.fillText(a.apply(this,e),0,0);var r=p.toDataURL();return s.clearRect(0,0,p.width,p.height),s.fillText(a.apply(this,t),0,0),r===p.toDataURL()}function l(e){if(!s||!s.fillText)return!1;switch(s.textBaseline="top",s.font="600 32px Arial",e){case"flag":return!c([127987,65039,8205,9895,65039],[127987,65039,8203,9895,65039])&&(!c([55356,56826,55356,56819],[55356,56826,8203,55356,56819])&&!c([55356,57332,56128,56423,56128,56418,56128,56421,56128,56430,56128,56423,56128,56447],[55356,57332,8203,56128,56423,8203,56128,56418,8203,56128,56421,8203,56128,56430,8203,56128,56423,8203,56128,56447]));case"emoji":return!c([55357,56424,55356,57342,8205,55358,56605,8205,55357,56424,55356,57340],[55357,56424,55356,57342,8203,55358,56605,8203,55357,56424,55356,57340])}return!1}function d(e){var t=a.createElement("script");t.src=e,t.defer=t.type="text/javascript",a.getElementsByTagName("head")[0].appendChild(t)}
EOL
}

# Function to create PHP files
create_php_files() {
    # Create inc directory if it doesn't exist
    if ! mkdir -p "${THEME_DIR}/inc"; then
        echo -e "${RED}Error: Failed to create inc directory${NC}"
        exit 1
    fi

    echo "Creating theme-setup.php..."
    local setup_file="${THEME_DIR}/inc/theme-setup.php"
    
    # Create the file with explicit error checking
    if ! cat > "$setup_file" << 'EOL'
<?php
/**
 * Theme setup and configuration
 *
 * @package StayNAlive
 */

namespace StayNAlive\Setup;

/**
 * Theme setup
 */
function theme_setup() {
    add_theme_support('wp-block-styles');
    add_theme_support('editor-styles');
    add_theme_support('responsive-embeds');
    add_theme_support('align-wide');
    add_theme_support('custom-units');
    add_theme_support('post-thumbnails');
    add_theme_support('title-tag');
    add_theme_support('automatic-feed-links');
    add_theme_support('html5', array(
        'comment-list',
        'comment-form', 
        'search-form',
        'gallery',
        'caption',
        'style',
        'script'
    ));
    add_theme_support('custom-logo');
    add_theme_support('custom-header');
    add_theme_support('custom-background');
    
    register_nav_menus(array(
        'primary' => __('Primary Menu', 'stay-n-alive'),
        'footer' => __('Footer Menu', 'stay-n-alive')
    ));
}
add_action('after_setup_theme', __NAMESPACE__ . '\theme_setup');

/**
 * Enqueue scripts and styles
 */
function enqueue_assets() {
    $version = wp_get_theme()->get('Version');
    
    wp_enqueue_style(
        'staynalive-style',
        get_stylesheet_uri(),
        array(),
        $version
    );
}
add_action('wp_enqueue_scripts', __NAMESPACE__ . '\enqueue_assets');
EOL
    then
        echo -e "${RED}Error: Failed to create theme-setup.php${NC}"
        exit 1
    fi

    # Verify file was created and has content
    if [ ! -f "$setup_file" ]; then
        echo -e "${RED}Error: theme-setup.php was not created${NC}"
        exit 1
    fi
    
    if [ ! -s "$setup_file" ]; then
        echo -e "${RED}Error: theme-setup.php is empty${NC}"
        exit 1
    fi
    
    echo -e "${GREEN}Successfully created theme-setup.php${NC}"
    ls -l "$setup_file"
    echo "First 10 lines of theme-setup.php:"
    head -n 10 "$setup_file"
}

# Function to create index.php
create_index_php() {
    cat > "${THEME_DIR}/index.php" << 'EOL'
<?php
// Silence is golden
EOL
}

# Function to create screenshot
create_screenshot() {
    # Create a basic screenshot using PowerShell
    powershell.exe -Command "
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
    "
    echo -e "${BLUE}Created screenshot.png (1200x900px)${NC}"
}

# Function to create zip file
create_zip() {
    log "Creating theme zip file..."
    
    echo "Current directory: $(pwd)"
    echo "Theme directory: ${THEME_DIR}"
    
    # Verify required files exist
    if [ ! -f "${THEME_DIR}/inc/theme-setup.php" ]; then
        echo -e "${RED}Error: theme-setup.php is missing${NC}"
        exit 1
    fi
    
    # Create zip with proper directory structure
    echo "Creating zip from: ${THEME_DIR}"
    
    # Make sure we're in the parent directory of the theme
    local parent_dir="$(dirname "${THEME_DIR}")"
    local theme_name="$(basename "${THEME_DIR}")"
    
    echo "Parent directory: ${parent_dir}"
    echo "Theme name: ${theme_name}"
    
    cd "${parent_dir}" || {
        echo -e "${RED}Error: Could not change to parent directory${NC}"
        exit 1
    }
    
    echo "Creating zip in: $(pwd)"
    echo "Contents to be zipped:"
    ls -la "${theme_name}"
    
    # Create the zip file
    if command -v zip >/dev/null 2>&1; then
        echo "Using zip command..."
        zip -r "stay-n-alive.zip" "${theme_name}" -x ".*" -x "__MACOSX" || {
            echo -e "${RED}Error: zip command failed${NC}"
            exit 1
        }
    else
        echo "Using PowerShell..."
        powershell.exe -Command "& {
            \$ErrorActionPreference = 'Stop';
            \$source = '${theme_name}/*';
            \$destination = '${parent_dir}/stay-n-alive.zip';
            
            Write-Host 'Source:' \$source;
            Write-Host 'Destination:' \$destination;
            
            # Create a temporary directory for the correct structure
            \$tempDir = 'temp_theme';
            New-Item -ItemType Directory -Path \$tempDir -Force | Out-Null;
            
            # Copy all files to temp directory (not in a subdirectory)
            Copy-Item -Path \$source -Destination \$tempDir -Recurse;
            
            # Verify style.css exists at root level
            if (-not (Test-Path \"\$tempDir/style.css\")) {
                Write-Error 'style.css not found at root level';
                exit 1;
            }
            
            # Create the zip from the temp directory contents
            Compress-Archive -Path \"\$tempDir/*\" -DestinationPath \$destination -Force;
            
            # Clean up temp directory
            Remove-Item -Path \$tempDir -Recurse -Force;
            
            if (Test-Path \$destination) {
                Write-Host 'Zip file created successfully';
                
                # Verify zip structure
                Expand-Archive -Path \$destination -DestinationPath 'temp_verify' -Force;
                if (Test-Path 'temp_verify/style.css') {
                    Write-Host 'style.css found at root level';
                    Get-ChildItem 'temp_verify' | ForEach-Object { Write-Host \$_.Name }
                } else {
                    Write-Error 'style.css not found at root level in zip';
                    Write-Host 'Zip contents:';
                    Get-ChildItem 'temp_verify' -Recurse;
                    exit 1;
                }
                Remove-Item -Path 'temp_verify' -Recurse -Force;
            } else {
                Write-Error 'Failed to create zip file';
                exit 1;
            }
        }" || {
            echo -e "${RED}Error: PowerShell zip creation failed${NC}"
            exit 1
        }
    fi
    
    # Verify zip was created
    if [ ! -f "stay-n-alive.zip" ]; then
        echo -e "${RED}Error: Zip file was not created${NC}"
        exit 1
    fi
    
    echo "Zip file created at: $(pwd)/stay-n-alive.zip"
    echo "Zip file size: $(ls -lh stay-n-alive.zip)"
    
    # Move back to original directory
    cd - || exit 1
}

# Function to create readme
create_readme() {
    cat > "${THEME_DIR}/readme.txt" << 'EOL'
=== Stay N Alive ===
Contributors: jessestay
Tags: blog, custom-background, custom-colors, custom-logo, custom-menu, editor-style, featured-images, footer-widgets, full-width-template, rtl-language-support, sticky-post, theme-options, threaded-comments, translation-ready, block-styles, wide-blocks
Requires at least: 6.0
Tested up to: 6.4
Requires PHP: 7.4
License: GPLv2 or later
License URI: http://www.gnu.org/licenses/gpl-2.0.html

A modern block-based WordPress theme designed for bloggers and content creators.

== Description ==

Stay N Alive is a modern block-based WordPress theme designed for bloggers and content creators.

== Installation ==

1. In your admin panel, go to Appearance > Themes and click the Add New button.
2. Click Upload Theme and Choose File, then select the theme's .zip file. Click Install Now.
3. Click Activate to use your new theme right away.

== Frequently Asked Questions ==

= Does this theme support any plugins? =

Stay N Alive includes support for WooCommerce and for Infinite Scroll in Jetpack.

== Changelog ==

= 1.0.0 =
* Initial release

== Copyright ==

Stay N Alive WordPress Theme, Copyright 2024 Jesse Stay
Stay N Alive is distributed under the terms of the GNU GPL
EOL
}

# Function to create functions.php
create_functions_php() {
    cat > "${THEME_DIR}/functions.php" << 'EOL'
<?php
/**
 * Stay N Alive Theme functions and definitions
 *
 * @package StayNAlive
 */

// Define theme version
define('STAYNALIVE_VERSION', '1.0.0');

// Require theme files
require_once get_template_directory() . '/inc/theme-setup.php';
require_once get_template_directory() . '/inc/social-feeds.php';
require_once get_template_directory() . '/inc/security.php';
require_once get_template_directory() . '/inc/performance.php';

// Add theme support
add_action('after_setup_theme', function() {
    add_theme_support('wp-block-styles');
    add_theme_support('editor-styles');
    add_theme_support('responsive-embeds');
    add_theme_support('align-wide');
    add_theme_support('custom-units');
    add_theme_support('post-thumbnails');
    add_theme_support('title-tag');
    add_theme_support('automatic-feed-links');
    add_theme_support('html5', array(
        'comment-list',
        'comment-form', 
        'search-form',
        'gallery',
        'caption',
        'style',
        'script'
    ));
    add_theme_support('custom-logo');
    add_theme_support('custom-header');
    add_theme_support('custom-background');
    
    register_nav_menus(array(
        'primary' => __('Primary Menu', 'stay-n-alive'),
        'footer' => __('Footer Menu', 'stay-n-alive')
    ));
});

// Enqueue scripts and styles
add_action('wp_enqueue_scripts', function() {
    wp_enqueue_style(
        'staynalive-style',
        get_stylesheet_uri(),
        array(),
        STAYNALIVE_VERSION
    );

    if (is_singular() && comments_open() && get_option('thread_comments')) {
        wp_enqueue_script('comment-reply');
    }
});

/**
 * Register widget areas
 */
function staynalive_widgets_init() {
    register_sidebar(array(
        'name'          => __('Blog Sidebar', 'stay-n-alive'),
        'id'            => 'sidebar-1',
        'description'   => __('Add widgets here to appear in your sidebar.', 'stay-n-alive'),
        'before_widget' => '<section id="%1$s" class="widget %2$s">',
        'after_widget'  => '</section>',
        'before_title'  => '<h2 class="widget-title">',
        'after_title'   => '</h2>',
    ));
}
add_action('widgets_init', 'staynalive_widgets_init');

function staynalive_register_block_styles() {
    // Quote styles
    register_block_style('core/quote', array(
        'name' => 'fancy-quote',
        'label' => __('Fancy Quote', 'stay-n-alive')
    ));
    
    // Button styles
    register_block_style('core/button', array(
        'name' => 'outline',
        'label' => __('Outline', 'stay-n-alive')
    ));

    // Group styles
    register_block_style('core/group', array(
        'name' => 'card',
        'label' => __('Card', 'stay-n-alive')
    ));
}
add_action('init', 'staynalive_register_block_styles');
EOL
}

# Function to validate theme
validate_theme() {
    log "Validating theme..."
    
    # Path to Local WordPress installation
    local wp_path="C:/Users/stay/Local Sites/staynalive/app/public"
    
    echo "Running comprehensive theme validation..."
    
    # 1. Check required files
    local required_files=(
        "style.css"
        "index.php"
        "functions.php"
        "screenshot.png"
        "inc/theme-setup.php"
    )
    
    for file in "${required_files[@]}"; do
        if [ ! -f "${THEME_DIR}/${file}" ]; then
            echo -e "${RED}Error: Required file missing: ${file}${NC}"
            exit 1
        fi
    done
    
    # 2. Validate style.css headers
    local required_headers=(
        "Theme Name:"
        "Theme URI:"
        "Author:"
        "Author URI:"
        "Description:"
        "Version:"
        "License:"
        "License URI:"
        "Text Domain:"
        "Tags:"
    )
    
    for header in "${required_headers[@]}"; do
        if ! grep -q "^${header}" "${THEME_DIR}/style.css"; then
            echo -e "${RED}Error: Missing required header in style.css: ${header}${NC}"
            exit 1
        fi
    done
    
    # 3. Check PHP syntax in all PHP files
    echo "Checking PHP syntax..."
    find "${THEME_DIR}" -name "*.php" -type f -exec php -l {} \;
    
    # 4. Check text domain usage
    echo "Checking text domain usage..."
    if ! grep -r "__(" "${THEME_DIR}" | grep -q "stay-n-alive"; then
        echo -e "${YELLOW}Warning: Text domain 'stay-n-alive' might not be used consistently${NC}"
    fi
    
    # 5. Check template hierarchy files
    local recommended_templates=(
        "404.html"
        "archive.html"
        "single.html"
        "index.php"
        "search.html"
    )
    
    for template in "${recommended_templates[@]}"; do
        if [ ! -f "${THEME_DIR}/templates/${template}" ]; then
            echo -e "${YELLOW}Warning: Recommended template file missing: templates/${template}${NC}"
        fi
    done
    
    # 6. Check for common security issues
    echo "Checking for security issues..."
    if grep -r "eval(" "${THEME_DIR}"; then
        echo -e "${RED}Error: Found eval() usage - potential security risk${NC}"
        exit 1
    fi
    
    # 7. Check file permissions
    echo "Checking file permissions..."
    find "${THEME_DIR}" -type f -exec stat -c "%a %n" {} \; | while read -r perm file; do
        if [ "$perm" -gt "755" ]; then
            echo -e "${YELLOW}Warning: File has too open permissions: ${file} (${perm})${NC}"
        fi
    done
    
    # 8. Validate functions.php
    echo "Validating functions.php..."
    if ! grep -q "add_action.*after_setup_theme" "${THEME_DIR}/functions.php"; then
        echo -e "${YELLOW}Warning: after_setup_theme hook might be missing${NC}"
    fi
    
    # 9. Check for debug code
    echo "Checking for debug code..."
    if grep -r "var_dump\|print_r\|error_reporting\|display_errors" "${THEME_DIR}"; then
        echo -e "${YELLOW}Warning: Found debug code that should be removed for production${NC}"
    fi
    
    # 10. Check for proper escaping
    echo "Checking for proper escaping..."
    if grep -r "echo \$" "${THEME_DIR}" | grep -v "esc_"; then
        echo -e "${YELLOW}Warning: Found potentially unescaped output${NC}"
    fi
    
    # 11. Run WP-CLI theme validation if available
    if command -v wp >/dev/null 2>&1; then
        echo "Running WP-CLI theme validation..."
        if ! wp theme validate-theme "${THEME_DIR}" --path="${wp_path}" --debug; then
            echo -e "${RED}WP-CLI theme validation failed${NC}"
            exit 1
        fi
    fi
    
    # 12. Validate theme-setup.php specifically
    echo "Validating theme-setup.php..."
    if [ -f "${THEME_DIR}/inc/theme-setup.php" ]; then
        # Check for namespace issues
        if grep -q "namespace" "${THEME_DIR}/inc/theme-setup.php"; then
            # Verify namespace is properly used
            if ! grep -q "add_action.*after_setup_theme.*__NAMESPACE__" "${THEME_DIR}/inc/theme-setup.php"; then
                echo -e "${RED}Error: theme-setup.php has namespace but isn't using __NAMESPACE__ in add_action${NC}"
                exit 1
            fi
            # Verify namespace matches expected (handle both single and double backslashes)
            if ! grep -q "namespace StayNAlive\\\\Setup\|namespace StayNAlive\\Setup\|namespace StayNAlive/Setup" "${THEME_DIR}/inc/theme-setup.php"; then
                echo -e "${RED}Error: theme-setup.php has incorrect namespace (should be StayNAlive\\Setup)${NC}"
                # Show actual namespace for debugging
                echo "Found namespace:"
                grep "namespace" "${THEME_DIR}/inc/theme-setup.php"
                exit 1
            fi
        fi

        # Check for required functions
        local required_functions=(
            "theme_setup"
            "enqueue_assets"
        )
        
        for func in "${required_functions[@]}"; do
            if ! grep -q "function.*${func}" "${THEME_DIR}/inc/theme-setup.php"; then
                echo -e "${RED}Error: Required function missing in theme-setup.php: ${func}${NC}"
                exit 1
            fi
        done

        # Check for required theme supports
        local required_supports=(
            "add_theme_support.*wp-block-styles"
            "add_theme_support.*editor-styles"
            "add_theme_support.*title-tag"
            "add_theme_support.*post-thumbnails"
            "add_theme_support.*html5"
        )
        
        for support in "${required_supports[@]}"; do
            if ! grep -q "${support}" "${THEME_DIR}/inc/theme-setup.php"; then
                echo -e "${YELLOW}Warning: Missing recommended theme support: ${support}${NC}"
            fi
        done

        # Check for proper menu registration
        if ! grep -q "register_nav_menus" "${THEME_DIR}/inc/theme-setup.php"; then
            echo -e "${YELLOW}Warning: No navigation menus registered in theme-setup.php${NC}"
        fi

        # Check for proper action hooks
        local required_hooks=(
            "after_setup_theme"
            "wp_enqueue_scripts"
        )
        
        for hook in "${required_hooks[@]}"; do
            if ! grep -q "add_action.*${hook}" "${THEME_DIR}/inc/theme-setup.php"; then
                echo -e "${RED}Error: Missing required action hook in theme-setup.php: ${hook}${NC}"
                exit 1
            fi
        done

        # Check for proper text domain usage
        if ! grep -q "__('.*', 'stay-n-alive')" "${THEME_DIR}/inc/theme-setup.php"; then
            echo -e "${YELLOW}Warning: Text domain 'stay-n-alive' not used in translations${NC}"
        fi
    else
        echo -e "${RED}Error: theme-setup.php not found${NC}"
        exit 1
    fi

    # 13. Check for proper file/directory structure
    echo "Checking theme directory structure..."
    local required_dirs=(
        "assets/css"
        "assets/js"
        "inc"
        "templates"
        "parts"
    )

    for dir in "${required_dirs[@]}"; do
        if [ ! -d "${THEME_DIR}/${dir}" ]; then
            echo -e "${RED}Error: Required directory missing: ${dir}${NC}"
            exit 1
        fi
    done

    # 14. Check for proper template parts
    echo "Checking template parts..."
    local required_parts=(
        "header"
        "footer"
    )

    for part in "${required_parts[@]}"; do
        if [ ! -f "${THEME_DIR}/parts/${part}.html" ]; then
            echo -e "${YELLOW}Warning: Recommended template part missing: parts/${part}.html${NC}"
        fi
    done

    # 15. Check for proper file permissions
    echo "Checking file permissions..."
    find "${THEME_DIR}" -type f -name "*.php" -exec stat -c "%a %n" {} \; | while read -r perm file; do
        if [ "$perm" -ne "644" ]; then
            echo -e "${YELLOW}Warning: PHP file has non-standard permissions: ${file} (${perm})${NC}"
        fi
    done
    
    echo -e "${GREEN}Theme validation completed successfully!${NC}"
}

# Add this function to debug file paths
debug_file_paths() {
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

# Add this to the create_zip function before creating the zip
debug_file_paths "${THEME_DIR}"

# Add this function to verify zip contents
verify_zip_contents() {
    local zip_file="$1"
    echo "Verifying zip contents..."
    
    # Create temp directory for zip verification
    local temp_dir="temp_verify_$(date +%s)"
    mkdir -p "$temp_dir"
    
    # Extract zip
    powershell.exe -Command "& {
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
    }"
    
    # Cleanup
    rm -rf "$temp_dir"
}

# Add this to create_zip after creating the zip
verify_zip_contents "stay-n-alive.zip"

# Main execution
main() {
    log "Creating Stay N Alive Theme..."
    
    # Clean up any existing theme directory
    if [ -d "${THEME_DIR}" ]; then
        # Force remove on Windows using cmd
        if [[ "$OSTYPE" == "msys" || "$OSTYPE" == "cygwin" ]]; then
            cmd //c "rmdir /s /q \"${THEME_DIR}\"" 2>/dev/null || true
        else
            rm -rf "${THEME_DIR}"
        fi
    fi
    
    # Create fresh theme structure
    create_directories
    create_all_templates
    create_template_parts
    create_style_css
    create_theme_json
    create_css_files
    create_all_css_files
    create_all_js_files
    create_block_patterns
    create_additional_patterns
    create_additional_css
    create_additional_js
    create_php_files
    create_functions_php
    create_index_php
    create_readme
    
    # Create screenshot
    create_screenshot
    
    # Create zip file
    create_zip
    
    # Validate theme
    validate_theme
    
    log "Theme files created successfully!"
    echo -e "Theme zip created at: ${BLUE}stay-n-alive.zip${NC}"
}

# Execute main function
main 