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
