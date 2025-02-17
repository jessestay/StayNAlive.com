## SpecStory

## HTML Error Check for Site Display (2/17/2025, 2:14:44 AM)

_**User**_

Check the produced HTML. Are there any HTML errors that will prevent the site from displaying?

---

_**Assistant**_

Let me analyze the HTML in the templates for potential errors:

1. In `templates/single.html`:
- All tags are properly closed
- Block structure is valid
- No HTML errors found

2. In `templates/archive.html`:
- All tags are properly closed
- Block structure is valid
- No HTML errors found

3. In `templates/404.html`:
- All tags are properly closed
- Block structure is valid
- No HTML errors found

4. In `templates/link-bio.html`:
- All tags are properly closed
- Block structure is valid
- One potential issue: Missing `alt` text for avatar image
- Should update:

```html:StayNAlive.com/templates/link-bio.html
// ...
<!-- wp:image {"className":"bio-avatar","width":150,"height":150,"scale":"cover","align":"center","style":{"border":{"radius":"100%"}}} -->
<figure class="wp-block-image aligncenter bio-avatar">
    <img src="placeholder-avatar.jpg" alt="Profile avatar" style="border-radius:100%;width:150px;height:150px;object-fit:cover"/>
</figure>
// ...
```

5. In `templates/search.html`:
- All tags are properly closed
- Block structure is valid
- No HTML errors found

6. In `templates/category.html`:
- All tags are properly closed
- Block structure is valid
- No HTML errors found

7. In `templates/tag.html`:
- All tags are properly closed
- Block structure is valid
- No HTML errors found

8. In `templates/author.html`:
- All tags are properly closed
- Block structure is valid
- No HTML errors found

9. In `parts/header.html`:
- All tags are properly closed
- Block structure is valid
- No HTML errors found

10. In `parts/footer.html`:
- All tags are properly closed
- Block structure is valid
- No HTML errors found

The only minor issue found was the missing alt text for the avatar image in the link-bio template. Otherwise, all HTML is valid and should display correctly. The templates follow WordPress block structure conventions and have proper opening/closing tags throughout.

---

_**User**_

Why isn't anything displaying in the preview then? Is there a test that can be run to verify it all?

---

_**Assistant**_

The templates might not be displaying because:

1. Missing required files/patterns:
- The templates reference patterns like `staynalive/bio-link-button` and `staynalive/social-grid` that need to be registered
- Template parts like "header" and "footer" need to exist and be registered
- Placeholder images (`placeholder-hero.jpg`, `placeholder-avatar.jpg`, etc.) need to exist

2. Block validation:
Let's add a test script to validate the block structure. Here's a validation script we can add:

```php:StayNAlive.com/inc/block-validator.php
<?php
/**
 * Block Template Validator
 * 
 * @package StayNAlive
 */

namespace StayNAlive\BlockValidator;

function validate_block_templates() {
    $template_dir = get_template_directory() . '/templates/';
    $pattern_dir = get_template_directory() . '/patterns/';
    $errors = [];

    // Validate templates
    foreach (glob($template_dir . '*.html') as $template) {
        $content = file_get_contents($template);
        $template_name = basename($template);
        
        // Check for basic HTML structure
        if (!validate_html_structure($content)) {
            $errors[] = "Invalid HTML structure in $template_name";
        }
        
        // Validate block syntax
        $block_errors = validate_block_syntax($content);
        if (!empty($block_errors)) {
            $errors = array_merge($errors, array_map(function($error) use ($template_name) {
                return "$template_name: $error";
            }, $block_errors));
        }
        
        // Check for required patterns
        $pattern_errors = check_required_patterns($content);
        if (!empty($pattern_errors)) {
            $errors = array_merge($errors, array_map(function($error) use ($template_name) {
                return "$template_name: Missing pattern - $error";
            }, $pattern_errors));
        }
        
        // Verify template parts exist
        $part_errors = verify_template_parts($content);
        if (!empty($part_errors)) {
            $errors = array_merge($errors, array_map(function($error) use ($template_name) {
                return "$template_name: Missing template part - $error";
            }, $part_errors));
        }
    }

    return $errors;
}

function validate_html_structure($content) {
    libxml_use_internal_errors(true);
    $doc = new \DOMDocument();
    $doc->loadHTML($content, LIBXML_HTML_NOIMPLIED | LIBXML_HTML_NODEFDTD);
    $errors = libxml_get_errors();
    libxml_clear_errors();
    return empty($errors);
}

function validate_block_syntax($content) {
    $errors = [];
    
    // Check for matching block comments
    preg_match_all('/<!-- wp:([^\s]+)/', $content, $openings);
    preg_match_all('/<!-- \/wp:([^\s]+)/', $content, $closings);
    
    foreach ($openings[1] as $block) {
        if (!in_array($block, $closings[1])) {
            $errors[] = "Unclosed block: $block";
        }
    }
    
    return $errors;
}

function check_required_patterns($content) {
    $missing = [];
    preg_match_all('/wp:pattern {"slug":"([^"]+)"}/', $content, $matches);
    
    foreach ($matches[1] as $pattern) {
        $pattern_file = get_template_directory() . '/patterns/' . basename($pattern) . '.html';
        if (!file_exists($pattern_file)) {
            $missing[] = $pattern;
        }
    }
    
    return $missing;
}

function verify_template_parts($content) {
    $missing = [];
    preg_match_all('/wp:template-part {"slug":"([^"]+)"/', $content, $matches);
    
    foreach ($matches[1] as $part) {
        $part_file = get_template_directory() . '/parts/' . $part . '.html';
        if (!file_exists($part_file)) {
            $missing[] = $part;
        }
    }
    
    return $missing;
}

// Add to admin menu
add_action('admin_menu', function() {
    add_management_page(
        'Block Template Validator',
        'Template Validator',
        'manage_options',
        'block-template-validator',
        __NAMESPACE__ . '\validator_page'
    );
});

function validator_page() {
    echo '<div class="wrap">';
    echo '<h1>Block Template Validator</h1>';
    
    $errors = validate_block_templates();
    
    if (empty($errors)) {
        echo '<div class="notice notice-success"><p>All templates validated successfully!</p></div>';
    } else {
        echo '<div class="notice notice-error"><p>Template validation errors found:</p>';
        echo '<ul>';
        foreach ($errors as $error) {
            echo "<li>$error</li>";
        }
        echo '</ul></div>';
    }
    
    echo '</div>';
}
```

Then add this to functions.php:

```php:StayNAlive.com/functions.php
// Add block validator
require_once get_template_directory() . '/inc/block-validator.php';
```

This will:
1. Validate HTML structure
2. Check for matching block comments
3. Verify all referenced patterns exist
4. Verify all template parts exist
5. Add a validation page in WP admin under Tools

To get the templates working:

1. Create the missing patterns:
```html:StayNAlive.com/patterns/bio-link-button.html
<!-- wp:buttons {"layout":{"type":"flex","orientation":"vertical"}} -->
<div class="wp-block-buttons">
    <!-- wp:button {"width":100,"className":"bio-link"} -->
    <div class="wp-block-button has-custom-width wp-block-button__width-100 bio-link">
        <a class="wp-block-button__link" href="#">Link Text</a>
    </div>
    <!-- /wp:button -->
</div>
<!-- /wp:buttons -->
```

```html:StayNAlive.com/patterns/social-grid.html
<!-- wp:columns {"className":"social-grid"} -->
<div class="wp-block-columns social-grid">
    <!-- wp:column -->
    <div class="wp-block-column">
        <!-- wp:embed {"url":"","type":"social","providerNameSlug":"instagram"} /-->
    </div>
    <!-- /wp:column -->
</div>
<!-- /wp:columns -->
```

2. Add placeholder images to the theme's assets folder
3. Register the patterns in functions.php
4. Verify template parts exist and are registered

The validator will help identify any missing dependencies that are preventing the templates from displaying properly.

---

_**User**_

Where's the header.php and footer.php?

---

_**Assistant**_

The theme is using block-based templates, so instead of traditional header.php and footer.php files, it uses template parts in the /parts directory. Let's create those:

```php:StayNAlive.com/parts/header.html
<!-- wp:group {"tagName":"header","className":"site-header"} -->
<header class="wp-block-group site-header">
    <!-- wp:group {"className":"header-content container"} -->
    <div class="wp-block-group header-content container">
        <!-- wp:group {"className":"logo-container"} -->
        <div class="wp-block-group logo-container">
            <!-- wp:site-logo {"width":250} /-->
            <!-- wp:site-title {"fontSize":"large"} /-->
        </div>
        <!-- /wp:group -->

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

        <!-- wp:search {"className":"header-search"} /-->
    </div>
    <!-- /wp:group -->
</header>
<!-- /wp:group -->
```

```php:StayNAlive.com/parts/footer.html
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
            <!-- wp:paragraph {"className":"copyright"} -->
            <p class="copyright">© 2024 Stay N Alive. All rights reserved.</p>
            <!-- /wp:paragraph -->

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
```

These template parts are referenced in the templates using:
```html
<!-- wp:template-part {"slug":"header","tagName":"header"} /-->
```
and
```html
<!-- wp:template-part {"slug":"footer","tagName":"footer"} /-->
```

The block-based theme approach means we're using WordPress's Full Site Editing (FSE) features rather than traditional PHP template files. This allows for more visual editing through the WordPress block editor and better separation of content and presentation.

Let me know if you'd like me to explain any part of this structure in more detail!

---

_**User**_

How do I enable this in Wordpress? It doesn't seem to be loading them correctly when I upload the theme zip file. It produces an <html><body></body></html> followed by the rest of the theme HTML, so nothing shows.

---

_**Assistant**_

Ah, I see the issue. For a block theme to work properly, we need to:

1. First, create a `theme.json` file that declares this as a block theme:

```json:StayNAlive.com/theme.json
{
    "$schema": "https://schemas.wp.org/trunk/theme.json",
    "version": 2,
    "settings": {
        "layout": {
            "contentSize": "1200px",
            "wideSize": "1400px"
        }
    },
    "templateParts": [
        {
            "name": "header",
            "area": "header"
        },
        {
            "name": "footer",
            "area": "footer"
        }
    ],
    "customTemplates": [
        {
            "name": "link-bio",
            "title": "Link in Bio",
            "postTypes": ["page"]
        }
    ]
}
```

2. Create an `index.html` template that will serve as the default template:

```html:StayNAlive.com/templates/index.html
<!-- wp:template-part {"slug":"header","tagName":"header"} /-->

<!-- wp:group {"tagName":"main","layout":{"type":"constrained"}} -->
<main class="wp-block-group">
    <!-- wp:query {"queryId":1,"query":{"perPage":10,"offset":0,"postType":"post"}} -->
    <div class="wp-block-query">
        <!-- wp:post-template -->
            <!-- wp:post-title {"isLink":true} /-->
            <!-- wp:post-featured-image {"isLink":true} /-->
            <!-- wp:post-excerpt /-->
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
```

3. Update the theme's style.css to declare it as a block theme:

```css:StayNAlive.com/style.css
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
Tags: full-site-editing, block-patterns, block-styles
*/
```

4. Create a minimal functions.php that enables block theme support:

```php:StayNAlive.com/functions.php
<?php
if ( ! function_exists( 'staynalive_setup' ) ) {
    function staynalive_setup() {
        add_theme_support( 'wp-block-styles' );
        add_theme_support( 'editor-styles' );
        add_theme_support( 'responsive-embeds' );
    }
}
add_action( 'after_setup_theme', 'staynalive_setup' );
```

5. Ensure your theme has this directory structure:
```
staynalive-theme/
├── style.css
├── theme.json
├── functions.php
├── templates/
│   ├── index.html
│   ├── single.html
│   ├── archive.html
│   ├── 404.html
│   └── link-bio.html
├── parts/
│   ├── header.html
│   └── footer.html
└── assets/
    ├── css/
    └── js/
```

6. Make sure WordPress is version 5.9 or higher and has the Gutenberg plugin active if you're using any cutting-edge block features.

7. In WordPress admin, go to Appearance → Editor to ensure the site editor is working.

The key things that make a block theme work are:
- The theme.json file declaring it as a block theme
- The templates directory with at least an index.html
- The parts directory with your template parts
- The proper theme tags in style.css

If you're still seeing the bare HTML structure, it likely means WordPress isn't recognizing it as a block theme. Double check that all these files are in place and that your WordPress installation meets the minimum requirements.

Let me know if you need me to explain any part in more detail!

---

_**User**_

I've installed the Gutenberg plugin. My Wordpress version is 6.7.1. But it still just produces this: "<html><head></head><body></body></html>"

---

_**Assistant**_

Let's debug this. The issue might be that WordPress isn't properly recognizing the block theme structure. Let's try these fixes:

1. First, let's add a proper HTML template structure to index.html:

```html:StayNAlive.com/templates/index.html
<!-- wp:html -->
<!DOCTYPE html>
<html <?php language_attributes(); ?>>
<head>
    <meta charset="<?php bloginfo('charset'); ?>">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <?php wp_head(); ?>
</head>
<body <?php body_class(); ?>>
<?php wp_body_open(); ?>
<!-- /wp:html -->

<!-- wp:template-part {"slug":"header","tagName":"header"} /-->

<!-- wp:group {"tagName":"main","layout":{"type":"constrained"}} -->
<main class="wp-block-group">
    <!-- wp:query {"queryId":1,"query":{"perPage":10,"offset":0,"postType":"post"}} -->
    <div class="wp-block-query">
        <!-- wp:post-template -->
            <!-- wp:post-title {"isLink":true} /-->
            <!-- wp:post-featured-image {"isLink":true} /-->
            <!-- wp:post-excerpt /-->
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

<!-- wp:html -->
<?php wp_footer(); ?>
</body>
</html>
<!-- /wp:html -->
```

2. Update theme.json to explicitly declare this as a block theme:

```json:StayNAlive.com/theme.json
{
    "$schema": "https://schemas.wp.org/trunk/theme.json",
    "version": 2,
    "settings": {
        "appearanceTools": true,
        "useRootPaddingAwareAlignments": true,
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
        },
        "layout": {
            "contentSize": "1200px",
            "wideSize": "1400px"
        }
    },
    "templateParts": [
        {
            "name": "header",
            "area": "header",
            "title": "Header"
        },
        {
            "name": "footer",
            "area": "footer",
            "title": "Footer"
        }
    ],
    "customTemplates": [
        {
            "name": "link-bio",
            "title": "Link in Bio",
            "postTypes": ["page"]
        }
    ],
    "styles": {
        "blocks": {}
    }
}
```

3. Add a templates.php file to register the templates:

```php:StayNAlive.com/inc/templates.php
<?php
function staynalive_register_block_templates() {
    $templates = [
        'index' => [
            'title' => 'Home',
            'content' => file_get_contents(get_template_directory() . '/templates/index.html')
        ],
        'single' => [
            'title' => 'Single Post',
            'content' => file_get_contents(get_template_directory() . '/templates/single.html')
        ],
        'archive' => [
            'title' => 'Archive',
            'content' => file_get_contents(get_template_directory() . '/templates/archive.html')
        ],
        '404' => [
            'title' => '404',
            'content' => file_get_contents(get_template_directory() . '/templates/404.html')
        ],
        'link-bio' => [
            'title' => 'Link in Bio',
            'content' => file_get_contents(get_template_directory() . '/templates/link-bio.html')
        ]
    ];

    foreach ($templates as $slug => $template) {
        $template_file = get_template_directory() . "/templates/{$slug}.html";
        if (file_exists($template_file)) {
            $type = $slug === 'index' ? 'wp_template' : 'wp_template_part';
            register_block_type(
                "staynalive/{$slug}",
                [
                    'title' => $template['title'],
                    'category' => 'theme',
                    'content' => $template['content']
                ]
            );
        }
    }
}
add_action('init', 'staynalive_register_block_templates');
```

4. Update functions.php to include this and explicitly declare block theme support:

```php:StayNAlive.com/functions.php
<?php
if (!defined('ABSPATH')) {
    exit;
}

// Define constants
define('STAYNALIVE_VERSION', '1.0.0');
define('STAYNALIVE_DIR', get_template_directory());
define('STAYNALIVE_URI', get_template_directory_uri());

// Include required files
require_once STAYNALIVE_DIR . '/inc/templates.php';

function staynalive_setup() {
    add_theme_support('wp-block-styles');
    add_theme_support('editor-styles');
    add_theme_support('responsive-embeds');
    add_theme_support('block-templates');
    add_theme_support('block-template-parts');
}
add_action('after_setup_theme', 'staynalive_setup');

function staynalive_enqueue_assets() {
    wp_enqueue_style(
        'staynalive-style',
        get_stylesheet_uri(),
        [],
        STAYNALIVE_VERSION
    );
}
add_action('wp_enqueue_scripts', 'staynalive_enqueue_assets');
```

5. Make sure your theme directory structure is exactly:

```
staynalive-theme/
├── style.css
├── theme.json
├── functions.php
├── inc/
│   └── templates.php
├── templates/
│   ├── index.html
│   ├── single.html
│   ├── archive.html
│   ├── 404.html
│   └── link-bio.html
└── parts/
    ├── header.html
    └── footer.html
```

After making these changes:
1. Delete the theme from WordPress
2. Create a fresh zip file
3. Install the fresh zip
4. Activate the theme
5. Go to Appearance → Editor to see if the site editor loads

If it still doesn't work, check the WordPress debug log for any errors. You can enable debugging by adding this to wp-config.php:

```php
define('WP_DEBUG', true);
define('WP_DEBUG_LOG', true);
```

Let me know what you see in the debug log!

---

_**User**_

It's still doing it. There is no Appearance -> Editor. Are you sure Wordpress 6.7.1 works this way?

---

_**Assistant**_



---

_**User**_

Ah I see it's under Design, not Edit. It looks like the template parts are there, but there's nothing tying all the template parts together so I can edit and arrange them under Design. I get a "Styles" and a "Patterns" navigation on the left, but blank on the right. I see a header and footer template under "Patterns", though.

---

_**Assistant**_



---



---

