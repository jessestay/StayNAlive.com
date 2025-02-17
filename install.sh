#!/usr/bin/env bash

# Exit on error, undefined variables, and pipe failures
set -euo pipefail

# Colors for output
readonly GREEN='\033[0;32m'
readonly BLUE='\033[0;34m'
readonly RED='\033[0;31m'
readonly NC='\033[0m'

# Theme directory name
readonly THEME_DIR="staynalive-theme"

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

# Function to create all templates
create_all_templates() {
    # Single template
    cat > "${THEME_DIR}/templates/single.html" << 'EOL'
<!-- wp:template-part {"slug":"header","tagName":"header"} /-->

<!-- wp:group {"tagName":"main","className":"site-main single-post"} -->
<main class="wp-block-group site-main single-post">
    <!-- wp:post-featured-image {"align":"wide"} /-->

    <!-- wp:group {"className":"post-header"} -->
    <div class="wp-block-group post-header">
        <!-- wp:post-title {"level":1} /-->

        <!-- wp:group {"className":"post-meta"} -->
        <div class="wp-block-group post-meta">
            <!-- wp:post-date /-->
            <!-- wp:post-author {"showAvatar":true} /-->
            <!-- wp:post-terms {"term":"category"} /-->
            <!-- wp:post-terms {"term":"post_tag"} /-->
        </div>
        <!-- /wp:group -->
    </div>
    <!-- /wp:group -->

    <!-- wp:post-content /-->

    <!-- wp:group {"className":"post-navigation"} -->
    <div class="wp-block-group post-navigation">
        <!-- wp:post-navigation-link {"type":"previous","showTitle":true,"linkLabel":"Previous:"} /-->
        <!-- wp:post-navigation-link {"type":"next","showTitle":true,"linkLabel":"Next:"} /-->
    </div>
    <!-- /wp:group -->

    <!-- wp:comments -->
    <div class="wp-block-comments">
        <!-- wp:comments-title /-->
        <!-- wp:comment-template -->
            <!-- wp:columns -->
            <div class="wp-block-columns">
                <!-- wp:column {"width":"40px"} -->
                <div class="wp-block-column" style="flex-basis:40px">
                    <!-- wp:avatar {"size":40} /-->
                </div>
                <!-- /wp:column -->

                <!-- wp:column -->
                <div class="wp-block-column">
                    <!-- wp:comment-author-name /-->
                    <!-- wp:group {"style":{"spacing":{"margin":{"top":"0px","bottom":"0px"}}}} -->
                    <div class="wp-block-group">
                        <!-- wp:comment-date /-->
                        <!-- wp:comment-edit-link /-->
                    </div>
                    <!-- /wp:group -->
                    <!-- wp:comment-content /-->
                    <!-- wp:comment-reply-link /-->
                </div>
                <!-- /wp:column -->
            </div>
            <!-- /wp:columns -->
        <!-- /wp:comment-template -->

        <!-- wp:comments-pagination -->
            <!-- wp:comments-pagination-previous /-->
            <!-- wp:comments-pagination-numbers /-->
            <!-- wp:comments-pagination-next /-->
        <!-- /wp:comments-pagination -->

        <!-- wp:post-comments-form /-->
    </div>
    <!-- /wp:comments -->
</main>
<!-- /wp:group -->

<!-- wp:template-part {"slug":"footer","tagName":"footer"} /-->
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
}

# Function to create template parts
create_template_parts() {
    # Header with all original functionality
    cat > "${THEME_DIR}/parts/header.html" << 'EOL'
<!-- wp:group {"tagName":"header","className":"site-header"} -->
<header class="wp-block-group site-header">
    <!-- wp:html -->
    <meta charset="UTF-8"/>
    <meta http-equiv="X-UA-Compatible" content="IE=edge">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <link rel="dns-prefetch" href="https://platform-api.sharethis.com/"/>
    <link rel="dns-prefetch" href="https://fonts.googleapis.com/"/>
    <link rel="dns-prefetch" href="https://s.w.org/"/>
    <link rel="alternate" type="application/rss+xml" title="Stay N Alive » Feed" href="/feed"/>
    <link rel="alternate" type="application/rss+xml" title="Stay N Alive » Comments Feed" href="/comments/feed"/>
    
    <script type="text/javascript">
        document.documentElement.className = 'js';
        var et_site_url='';
        var et_post_id='36';
        function et_core_page_resource_fallback(a,b){"undefined"===typeof b&&(b=a.sheet.cssRules&&0===a.sheet.cssRules.length);b&&(a.onerror=null,a.onload=null,a.href?a.href=et_site_url+"/?et_core_page_resource="+a.id+et_post_id:a.src&&(a.src=et_site_url+"/?et_core_page_resource="+a.id+et_post_id))}
    </script>
    
    <!-- ShareThis Integration -->
    <script type="text/javascript" src="//platform-api.sharethis.com/js/sharethis.js#property=your_property_id"></script>
    <!-- /wp:html -->

    <!-- wp:group {"className":"header-content container"} -->
    <div class="wp-block-group header-content container">
        <!-- wp:group {"className":"logo_container"} -->
        <div class="wp-block-group logo_container">
            <!-- wp:site-logo {"width":300} /-->
        </div>
        <!-- /wp:group -->

        <!-- wp:group {"className":"et-top-navigation"} -->
        <div class="wp-block-group et-top-navigation">
            <!-- wp:navigation {"className":"primary-navigation"} -->
            <!-- wp:navigation-link {"label":"Services","url":"/services"} /-->
            <!-- wp:navigation-link {"label":"Clients","url":"/clients"} /-->
            <!-- wp:navigation-link {"label":"The Blog","url":"/blog"} /-->
            <!-- wp:navigation-submenu {"label":"About SNA","url":"/about"} -->
                <!-- wp:navigation-link {"label":"About Jesse","url":"/jessestay"} /-->
                <!-- wp:navigation-link {"label":"Jesse's Books","url":"/jessestay/books"} /-->
            <!-- /wp:navigation-submenu -->
            <!-- wp:navigation-link {"label":"Contact","url":"/contact"} /-->
            <!-- /wp:navigation -->

            <!-- wp:search {"className":"et_search_outer"} /-->
        </div>
        <!-- /wp:group -->
    </div>
    <!-- /wp:group -->
</header>
<!-- /wp:group -->
EOL

    # Footer
    cat > "${THEME_DIR}/parts/footer.html" << 'EOL'
<!-- wp:group {"tagName":"footer","className":"site-footer"} -->
<footer class="wp-block-group site-footer">
    <!-- wp:group {"className":"footer-widgets"} -->
    <div class="wp-block-group footer-widgets">
        <div class="container">
            <!-- wp:columns {"className":"clearfix"} -->
            <div class="wp-block-columns clearfix">
                <!-- wp:column {"className":"footer-widget"} -->
                <div class="wp-block-column footer-widget">
                    <!-- wp:image {"src":"/wp-content/uploads/SNA-logo-final-white.png"} /-->
                    <!-- wp:paragraph -->
                    <p>E. – info@staynalive.com</p>
                    <p>P. – 801-853-8339</p>
                    <p>L. – Salt Lake City, UT, USA</p>
                    <!-- /wp:paragraph -->
                </div>
                <!-- /wp:column -->
                
                <!-- wp:column {"className":"footer-widget"} -->
                <div class="wp-block-column footer-widget">
                    <!-- wp:heading {"level":4,"className":"title"} -->
                    <h4 class="title">The Blog</h4>
                    <!-- /wp:heading -->
                    <!-- wp:latest-posts {"postsToShow":5} /-->
                </div>
                <!-- /wp:column -->
            </div>
            <!-- /wp:columns -->
        </div>
    </div>
    <!-- /wp:group -->

    <!-- wp:group {"className":"footer-bottom"} -->
    <div class="wp-block-group footer-bottom">
        <div class="container">
            <!-- wp:social-links {"className":"et-social-icons"} -->
            <ul class="wp-block-social-links et-social-icons">
                <!-- wp:social-link {"url":"http://facebook.com/staynalivellc","service":"facebook"} /-->
                <!-- wp:social-link {"url":"http://twitter.com/jesse","service":"twitter"} /-->
                <!-- wp:social-link {"url":"/feed/","service":"feed"} /-->
            </ul>
            <!-- /wp:social-links -->
        </div>
    </div>
    <!-- /wp:group -->
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
[type=button]:-moz-focusring,[type=reset]:-moz-focusring,[type=submit]:-moz-focusring,button:-moz-focus-ring{outline:1px dotted ButtonText}
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
    # Social Media Integration
    cat > "${THEME_DIR}/inc/social-feeds.php" << 'EOL'
<?php
/**
 * Social Media Feed Integration
 *
 * @package StayNAlive
 */

namespace StayNAlive\SocialFeeds;

// Register REST API endpoints
add_action('rest_api_init', function() {
    register_rest_route('staynalive/v1', '/instagram-feed', [
        'methods' => 'GET',
        'callback' => __NAMESPACE__ . '\get_instagram_feed',
        'permission_callback' => '__return_true'
    ]);
    
    register_rest_route('staynalive/v1', '/tiktok-feed', [
        'methods' => 'GET',
        'callback' => __NAMESPACE__ . '\get_tiktok_feed',
        'permission_callback' => '__return_true'
    ]);
    
    register_rest_route('staynalive/v1', '/youtube-feed', [
        'methods' => 'GET',
        'callback' => __NAMESPACE__ . '\get_youtube_feed',
        'permission_callback' => '__return_true'
    ]);
});

function get_instagram_feed() {
    $options = get_option('staynalive_social_media', []);
    $token = $options['instagram_token'] ?? '';
    
    if (empty($token)) {
        return new \WP_Error('missing_token', 'Instagram token is required');
    }
    
    $cache_key = 'instagram_feed_' . md5($token);
    $cached = get_transient($cache_key);
    
    if (false !== $cached) {
        return $cached;
    }
    
    $response = wp_remote_get(
        "https://graph.instagram.com/me/media?fields=id,caption,media_type,media_url,thumbnail_url,permalink&access_token={$token}"
    );
    
    if (is_wp_error($response)) {
        return $response;
    }
    
    $data = json_decode(wp_remote_retrieve_body($response), true);
    set_transient($cache_key, $data, HOUR_IN_SECONDS);
    
    return $data;
}

function get_youtube_feed() {
    $options = get_option('staynalive_social_media', []);
    $api_key = $options['youtube_api_key'] ?? '';
    $channel_id = $options['youtube_channel_id'] ?? '';
    
    if (empty($api_key) || empty($channel_id)) {
        return new \WP_Error('missing_config', 'YouTube API key and channel ID are required');
    }
    
    $cache_key = 'youtube_feed_' . md5($api_key . $channel_id);
    $cached = get_transient($cache_key);
    
    if (false !== $cached) {
        return $cached;
    }
    
    $response = wp_remote_get(
        "https://www.googleapis.com/youtube/v3/search?part=snippet&channelId={$channel_id}&maxResults=10&order=date&type=video&key={$api_key}"
    );
    
    if (is_wp_error($response)) {
        return $response;
    }
    
    $data = json_decode(wp_remote_retrieve_body($response), true);
    set_transient($cache_key, $data, HOUR_IN_SECONDS);
    
    return $data;
}
EOL

    # Theme Setup
    cat > "${THEME_DIR}/inc/theme-setup.php" << 'EOL'
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
    
    // Register block patterns
    if (function_exists('register_block_pattern_category')) {
        register_block_pattern_category(
            'staynalive',
            ['label' => __('Stay N Alive', 'staynalive')]
        );
    }
}
add_action('after_setup_theme', __NAMESPACE__ . '\theme_setup');

/**
 * Enqueue scripts and styles
 */
function enqueue_assets() {
    $version = wp_get_theme()->get('Version');
    
    // Styles
    wp_enqueue_style(
        'staynalive-style',
        get_stylesheet_uri(),
        [],
        $version
    );
    
    // Scripts
    wp_enqueue_script(
        'staynalive-social-feed',
        get_template_directory_uri() . '/assets/js/social-feed.js',
        [],
        $version,
        true
    );
    
    wp_enqueue_script(
        'staynalive-animations',
        get_template_directory_uri() . '/assets/js/animations.js',
        [],
        $version,
        true
    );
}
add_action('wp_enqueue_scripts', __NAMESPACE__ . '\enqueue_assets');
EOL
}

# Function to create utility files
create_utility_files() {
    # Security Functions
    cat > "${THEME_DIR}/inc/security.php" << 'EOL'
<?php
/**
 * Security enhancements
 *
 * @package StayNAlive
 */

namespace StayNAlive\Security;

// Disable file editing in WordPress admin
if (!defined('DISALLOW_FILE_EDIT')) {
    define('DISALLOW_FILE_EDIT', true);
}

// Remove WordPress version from sources
remove_action('wp_head', 'wp_generator');

// Add security headers
add_action('send_headers', function() {
    header('X-Content-Type-Options: nosniff');
    header('X-Frame-Options: SAMEORIGIN');
    header('X-XSS-Protection: 1; mode=block');
    header('Referrer-Policy: strict-origin-when-cross-origin');
});

// Sanitize SVG uploads
add_filter('wp_handle_upload_prefilter', function($file) {
    if ($file['type'] === 'image/svg+xml') {
        if (!sanitize_svg($file['tmp_name'])) {
            $file['error'] = 'Invalid SVG file';
        }
    }
    return $file;
});
EOL

    # Performance Functions
    cat > "${THEME_DIR}/inc/performance.php" << 'EOL'
<?php
/**
 * Performance optimizations
 *
 * @package StayNAlive
 */

namespace StayNAlive\Performance;

// Remove unnecessary meta tags
remove_action('wp_head', 'wlwmanifest_link');
remove_action('wp_head', 'rsd_link');
remove_action('wp_head', 'wp_shortlink_wp_head');

// Disable emoji scripts
add_action('init', function() {
    remove_action('wp_head', 'print_emoji_detection_script', 7);
    remove_action('admin_print_scripts', 'print_emoji_detection_script');
    remove_action('wp_print_styles', 'print_emoji_styles');
    remove_action('admin_print_styles', 'print_emoji_styles');
    remove_filter('the_content_feed', 'wp_staticize_emoji');
    remove_filter('comment_text_rss', 'wp_staticize_emoji');
    remove_filter('wp_mail', 'wp_staticize_emoji_for_email');
});

// Add preload for critical assets
add_action('wp_head', function() {
    echo '<link rel="preload" href="' . get_theme_file_uri('assets/css/base/base.css') . '" as="style">';
    echo '<link rel="preload" href="' . get_theme_file_uri('assets/js/animations.js') . '" as="script">';
}, 1);
?>
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
});

// Enqueue scripts and styles
add_action('wp_enqueue_scripts', function() {
    // Base styles
    wp_enqueue_style('staynalive-base', get_template_directory_uri() . '/assets/css/base/base.css', [], STAYNALIVE_VERSION);
    
    // Component styles
    wp_enqueue_style('staynalive-header', get_template_directory_uri() . '/assets/css/components/header.css', [], STAYNALIVE_VERSION);
    wp_enqueue_style('staynalive-footer', get_template_directory_uri() . '/assets/css/components/footer.css', [], STAYNALIVE_VERSION);
    wp_enqueue_style('staynalive-social-feed', get_template_directory_uri() . '/assets/css/components/social-feed.css', [], STAYNALIVE_VERSION);
    
    // Scripts
    wp_enqueue_script('staynalive-social-feed', get_template_directory_uri() . '/assets/js/social-feed.js', [], STAYNALIVE_VERSION, true);
    wp_enqueue_script('staynalive-animations', get_template_directory_uri() . '/assets/js/animations.js', [], STAYNALIVE_VERSION, true);

    // Additional styles
    wp_enqueue_style('staynalive-divi-compat', get_template_directory_uri() . '/assets/css/compatibility/divi.css', [], STAYNALIVE_VERSION);
    wp_enqueue_style('staynalive-mobile-menu', get_template_directory_uri() . '/assets/css/components/mobile-menu.css', [], STAYNALIVE_VERSION);
    
    // Additional scripts
    wp_enqueue_script('staynalive-google-maps', get_template_directory_uri() . '/assets/js/google-maps.js', [], STAYNALIVE_VERSION, true);
    wp_enqueue_script('staynalive-analytics', get_template_directory_uri() . '/assets/js/analytics.js', ['jquery'], STAYNALIVE_VERSION, true);

    // Add to wp_enqueue_scripts function
    wp_enqueue_style('staynalive-normalize', get_template_directory_uri() . '/assets/css/base/normalize.css', [], STAYNALIVE_VERSION);
    wp_enqueue_style('staynalive-divi-legacy', get_template_directory_uri() . '/assets/css/compatibility/divi-legacy.css', [], STAYNALIVE_VERSION);
    
    wp_enqueue_script('staynalive-sharethis', get_template_directory_uri() . '/assets/js/sharethis.js', [], STAYNALIVE_VERSION, true);
    wp_enqueue_script('staynalive-emoji', get_template_directory_uri() . '/assets/js/emoji.js', [], STAYNALIVE_VERSION, true);
});
EOL
}

# Function to create index.php
create_index_php() {
    cat > "${THEME_DIR}/index.php" << 'EOL'
<?php
// Silence is golden
EOL
}

# Function to create zip file
create_zip() {
    log "Creating theme zip file..."
    (cd "${THEME_DIR}" && zip -r ../staynalive-theme.zip .)
}

# Function to clean up on error
cleanup() {
    if [[ $? -ne 0 ]]; then
        echo -e "${RED}An error occurred. Cleaning up...${NC}"
        rm -rf "${THEME_DIR}" staynalive-theme.zip
    fi
}

# Register cleanup function
# trap cleanup EXIT

# Main execution
main() {
    log "Creating Stay N Alive Theme..."
    
    # Verify required commands
    if ! command -v zip >/dev/null 2>&1; then
        echo -e "${RED}Error: zip command not found. Please install zip first.${NC}"
        exit 1
    fi
    
    # Clean up any existing theme directory
    rm -rf "${THEME_DIR}"
    
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
    create_utility_files
    create_functions_php
    create_index_php
    
    # Create zip file
    create_zip
    
    log "Theme files created successfully!"
    echo -e "Theme zip created at: ${BLUE}staynalive-theme.zip${NC}"
}

# Execute main function
main 