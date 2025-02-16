<?php
/**
 * Jetpack Integration for Stay N Alive Theme
 *
 * @package staynalive
 */

/**
 * Jetpack setup function.
 */
function staynalive_jetpack_setup() {
    // Add theme support for Infinite Scroll
    add_theme_support(
        'infinite-scroll',
        array(
            'container'      => 'wp-block-query',
            'wrapper'        => false,
            'render'         => 'staynalive_infinite_scroll_render',
            'footer'         => false,
            'footer_widgets' => false,
            'posts_per_page' => get_option('posts_per_page'),
        )
    );

    // Add theme support for Responsive Videos
    add_theme_support('jetpack-responsive-videos');

    // Add theme support for Content Options
    add_theme_support(
        'jetpack-content-options',
        array(
            'post-details'    => array(
                'stylesheet' => 'staynalive-style',
                'date'      => '.wp-block-post-date',
                'categories'=> '.wp-block-post-terms.category',
                'tags'      => '.wp-block-post-terms.post_tag',
                'author'    => '.wp-block-post-author',
            ),
            'featured-images' => array(
                'archive'     => true,
                'post'       => true,
                'page'       => true,
                'fallback'   => false,
            ),
        )
    );

    // Add support for Social Menus
    add_theme_support('jetpack-social-menu', 'svg');
}
add_action('after_setup_theme', 'staynalive_jetpack_setup');

/**
 * Custom render function for Infinite Scroll.
 */
function staynalive_infinite_scroll_render() {
    while (have_posts()) {
        the_post();
        ?>
        <!-- wp:group {"className":"post-item"} -->
        <div class="wp-block-group post-item">
            <!-- wp:post-featured-image {"isLink":true} /-->
            
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
        <?php
    }
}

/**
 * Modify Jetpack's Content Options.
 *
 * @param array $options
 * @return array
 */
function staynalive_jetpack_content_options($options) {
    $options['featured-images']['archive-default'] = true;
    $options['featured-images']['post-default'] = true;
    $options['featured-images']['page-default'] = true;
    
    return $options;
}
add_filter('jetpack_content_options_defaults', 'staynalive_jetpack_content_options');

/**
 * Add custom block styles for Jetpack blocks
 */
function staynalive_jetpack_block_styles() {
    if (!function_exists('register_block_style')) {
        return;
    }

    register_block_style(
        'jetpack/slideshow',
        array(
            'name'  => 'borderless',
            'label' => __('Borderless', 'staynalive'),
        )
    );
}
add_action('init', 'staynalive_jetpack_block_styles');

/**
 * Add custom CSS for Jetpack features
 */
function staynalive_jetpack_styles() {
    wp_add_inline_style('staynalive-style', '
        .infinite-scroll .wp-block-query-pagination {
            display: none;
        }
        
        .infinite-loader {
            margin: 40px auto;
        }
        
        #infinite-handle {
            text-align: center;
            margin: 40px 0;
        }
        
        #infinite-handle span {
            background: var(--wp--preset--color--primary);
            color: var(--wp--preset--color--background);
            padding: 12px 24px;
            border-radius: 4px;
            cursor: pointer;
            transition: opacity 0.2s;
        }
        
        #infinite-handle span:hover {
            opacity: 0.9;
        }
    ');
}
add_action('wp_enqueue_scripts', 'staynalive_jetpack_styles'); 