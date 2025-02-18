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
    add_theme_support('register-block-style');
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
