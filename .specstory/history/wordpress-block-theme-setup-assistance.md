## SpecStory

## WordPress Block Theme Setup Assistance (2/17/2025, 11:03:53 AM)

_**User**_

Let's continue the conversation. Ah I see it's under Design, not Edit. It looks like the template parts are there, but there's nothing tying all the template parts together so I can edit and arrange them under Design. I get a "Styles" and a "Patterns" navigation on the left, but blank on the right. I see a header and footer template under "Patterns", though.

---

_**Assistant**_

Let's fix this by properly registering the block templates. The issue is that WordPress needs a proper template hierarchy. Here's what we need to update:

1. First, let's create a proper `templates/index.html` as the main template:

```html:StayNAlive.com/templates/index.html
<!-- wp:group {"tagName":"div","layout":{"type":"default"}} -->
<div class="wp-block-group">
    <!-- wp:template-part {"slug":"header","theme":"staynalive"} /-->

    <!-- wp:group {"tagName":"main","layout":{"type":"constrained"}} -->
    <main class="wp-block-group">
        <!-- wp:query {"queryId":1,"query":{"perPage":10,"offset":0,"postType":"post","order":"desc","orderBy":"date","author":"","search":"","sticky":"","inherit":false}} -->
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

    <!-- wp:template-part {"slug":"footer","theme":"staynalive"} /-->
</div>
<!-- /wp:group -->
```

2. Update `theme.json` to properly register templates:

```json:StayNAlive.com/theme.json
{
    "$schema": "https://schemas.wp.org/trunk/theme.json",
    "version": 2,
    "settings": {
        "appearanceTools": true,
        "layout": {
            "contentSize": "1200px",
            "wideSize": "1400px"
        }
    },
    "customTemplates": [
        {
            "name": "single",
            "title": "Single Post",
            "postTypes": ["post"]
        },
        {
            "name": "archive",
            "title": "Archive",
            "postTypes": ["post"]
        },
        {
            "name": "404",
            "title": "404",
            "postTypes": ["page"]
        },
        {
            "name": "link-bio",
            "title": "Link in Bio",
            "postTypes": ["page"]
        }
    ],
    "templateParts": [
        {
            "name": "header",
            "title": "Header",
            "area": "header"
        },
        {
            "name": "footer",
            "title": "Footer",
            "area": "footer"
        }
    ]
}
```

3. Update `functions.php` to properly register block theme support:

```php:StayNAlive.com/functions.php
<?php
if (!defined('ABSPATH')) {
    exit;
}

// Define constants
define('STAYNALIVE_VERSION', '1.0.0');
define('STAYNALIVE_DIR', get_template_directory());
define('STAYNALIVE_URI', get_template_directory_uri());

function staynalive_setup() {
    // Add block theme support
    add_theme_support('wp-block-styles');
    add_theme_support('editor-styles');
    add_theme_support('block-templates');
    add_theme_support('block-template-parts');
    
    // Register block patterns
    register_block_pattern_category(
        'staynalive',
        array('label' => __('Stay N Alive', 'staynalive'))
    );
}
add_action('after_setup_theme', 'staynalive_setup');

function staynalive_enqueue_assets() {
    wp_enqueue_style(
        'staynalive-style',
        get_stylesheet_uri(),
        array(),
        STAYNALIVE_VERSION
    );
}
add_action('wp_enqueue_scripts', 'staynalive_enqueue_assets');
```

4. Make sure your directory structure is exactly:

```
staynalive-theme/
├── style.css
├── theme.json
├── functions.php
├── templates/
│   ├── index.html      # Main template
│   ├── single.html     # Single post template
│   ├── archive.html    # Archive template
│   ├── 404.html        # 404 template
│   └── link-bio.html   # Custom template
└── parts/
    ├── header.html     # Header template part
    └── footer.html     # Footer template part
```

After making these changes:
1. Delete the current theme
2. Create a new zip file
3. Install the fresh zip
4. Activate the theme
5. Go to Design → Editor

You should now see the template editor with the ability to edit and arrange template parts. The key changes are:
- Proper template hierarchy starting with index.html
- Correct registration of templates and template parts in theme.json
- Proper block theme support in functions.php

Let me know if you still have issues!

---

_**User**_

Still nothing. I also notice there's no option to view the theme files under Appearance.  Are you sure this is compatible with my version of Wordpress?

---

_**Assistant**_



---



---

