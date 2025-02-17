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
