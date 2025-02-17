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
