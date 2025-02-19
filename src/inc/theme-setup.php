<?php
/**
 * Theme setup and configuration
 *
 * @package Stay_N_Alive
 */

namespace StayNAlive\Setup;

if (!defined('ABSPATH')) {
    exit; // Exit if accessed directly
}

/**
 * Theme setup
 */
function theme_setup() {
    // Add default posts and comments RSS feed links to head
    add_theme_support('automatic-feed-links');

    // Let WordPress manage the document title
    add_theme_support('title-tag');

    // Enable support for Post Thumbnails
    add_theme_support('post-thumbnails');

    // Register nav menus
    register_nav_menus(array(
        'primary' => __('Primary Menu', 'stay-n-alive'),
        'footer'  => __('Footer Menu', 'stay-n-alive'),
        'social'  => __('Social Links Menu', 'stay-n-alive'),
    ));

    // Switch default core markup to output valid HTML5
    add_theme_support('html5', array(
        'search-form',
        'comment-form',
        'comment-list',
        'gallery',
        'caption',
        'style',
        'script',
    ));

    // Add theme support for selective refresh for widgets
    add_theme_support('customize-selective-refresh-widgets');

    // Add support for Block Styles
    add_theme_support('wp-block-styles');

    // Add support for full and wide align images
    add_theme_support('align-wide');

    // Add support for editor styles
    add_theme_support('editor-styles');

    // Add support for responsive embeds
    add_theme_support('responsive-embeds');

    // Add support for custom line height controls
    add_theme_support('custom-line-height');

    // Add support for experimental link color control
    add_theme_support('experimental-link-color');

    // Add support for custom units
    add_theme_support('custom-units');
}
add_action('after_setup_theme', __NAMESPACE__ . '\theme_setup');
