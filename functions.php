<?php
// At the top of the file
require_once get_template_directory() . '/inc/template-loader.php';

function stay_n_alive_setup() {
    // Add theme support
    add_theme_support('title-tag');
    add_theme_support('post-thumbnails');
    add_theme_support('custom-background');
    add_theme_support('custom-header');
    add_theme_support('editor-styles');

    // Register block styles
    register_block_style(
        'core/button',
        array(
            'name'  => 'stay-n-alive-button',
            'label' => __('Stay N Alive Style', 'stay-n-alive'),
        )
    );
    
    register_block_style(
        'core/heading',
        array(
            'name'  => 'stay-n-alive-heading',
            'label' => __('Stay N Alive Style', 'stay-n-alive'),
        )
    );

    register_block_style(
        'core/paragraph',
        array(
            'name'  => 'stay-n-alive-paragraph',
            'label' => __('Stay N Alive Style', 'stay-n-alive'),
        )
    );
    
    register_block_style(
        'core/image',
        array(
            'name'  => 'stay-n-alive-image',
            'label' => __('Stay N Alive Style', 'stay-n-alive'),
        )
    );

    // Register nav menus
    register_nav_menus(array(
        'primary' => __('Primary Menu', 'stay-n-alive'),
        'footer'  => __('Footer Menu', 'stay-n-alive'),
    ));

    // Add editor styles
    add_editor_style('assets/css/blocks/custom-styles.css');

    // Add support for responsive embeds
    add_theme_support('responsive-embeds');
    
    // Add support for HTML5 features
    add_theme_support('html5', array(
        'navigation-widgets',
        'search-form',
        'gallery',
        'caption',
        'style',
        'script'
    ));
}
add_action('after_setup_theme', 'stay_n_alive_setup');

// Add after existing setup code
function stay_n_alive_register_patterns() {
    register_block_pattern_category(
        'staynalive',
        array('label' => __('Stay N Alive', 'stay-n-alive'))
    );

    register_block_pattern(
        'staynalive/hero-section',
        array(
            'title'       => __('Hero Section', 'stay-n-alive'),
            'categories'  => array('staynalive'),
            'content'     => file_get_contents(get_template_directory() . '/patterns/hero-section.html')
        )
    );
    
    register_block_pattern(
        'staynalive/expertise-section',
        array(
            'title'       => __('Expertise Section', 'stay-n-alive'),
            'categories'  => array('staynalive'),
            'content'     => file_get_contents(get_template_directory() . '/patterns/expertise-section.html')
        )
    );

    register_block_pattern(
        'staynalive/featured-posts',
        array(
            'title'       => __('Featured Posts Grid', 'stay-n-alive'),
            'categories'  => array('staynalive'),
            'content'     => file_get_contents(get_template_directory() . '/patterns/featured-posts.html')
        )
    );

    register_block_pattern(
        'staynalive/cta-section',
        array(
            'title'       => __('Call to Action Section', 'stay-n-alive'),
            'categories'  => array('staynalive'),
            'content'     => file_get_contents(get_template_directory() . '/patterns/cta-section.html')
        )
    );

    register_block_pattern(
        'staynalive/background-pattern',
        array(
            'title'       => __('Background Pattern', 'stay-n-alive'),
            'categories'  => array('staynalive'),
            'content'     => file_get_contents(get_template_directory() . '/patterns/background-pattern.html')
        )
    );
}
add_action('init', 'stay_n_alive_register_patterns');

function stay_n_alive_enqueue_styles() {
    wp_enqueue_style(
        'stay-n-alive-custom-styles',
        get_template_directory_uri() . '/assets/css/blocks/custom-styles.css',
        array(),
        wp_get_theme()->get('Version')
    );

    wp_enqueue_style(
        'staynalive-blocks',
        get_template_directory_uri() . '/assets/css/blocks/custom-styles.css',
        array(),
        wp_get_theme()->get('Version')
    );
}
add_action('wp_enqueue_scripts', 'stay_n_alive_enqueue_styles');

// Add debugging for template loading
function stay_n_alive_debug_template($template) {
    error_log('Template being loaded: ' . $template);
    error_log('Is front page: ' . (is_front_page() ? 'yes' : 'no'));
    error_log('Is home: ' . (is_home() ? 'yes' : 'no'));
    error_log('Query type: ' . get_query_var('post_type'));
    error_log('Page ID: ' . get_queried_object_id());
    
    // Force front-page.html for homepage
    if (is_front_page()) {
        $front_template = get_theme_file_path('templates/front-page.html');
        if (file_exists($front_template)) {
            return $front_template;
        }
    }
    
    return $template;
}
add_filter('template_include', 'stay_n_alive_debug_template');

// Debug homepage settings
function stay_n_alive_debug_homepage() {
    error_log('Show on front: ' . get_option('show_on_front'));
    error_log('Page on front: ' . get_option('page_on_front'));
    error_log('Current page ID: ' . get_queried_object_id());
}
add_action('template_redirect', 'stay_n_alive_debug_homepage'); 