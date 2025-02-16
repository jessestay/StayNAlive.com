<?php
/**
 * Theme functions and definitions
 *
 * @package staynalive
 */

// Define constants
define('STAYNALIVE_VERSION', '2.0.0');
define('STAYNALIVE_DIR', get_template_directory());
define('STAYNALIVE_URI', get_template_directory_uri());

// Required files
require STAYNALIVE_DIR . '/inc/template-functions.php';
require STAYNALIVE_DIR . '/inc/template-tags.php';
require STAYNALIVE_DIR . '/inc/block-patterns.php';

/**
 * Theme Setup
 */
function staynalive_setup() {
    // Theme support
    add_theme_support('wp-block-styles');
    add_theme_support('responsive-embeds');
    add_theme_support('editor-styles');
    add_theme_support('html5');
    add_theme_support('automatic-feed-links');
    add_theme_support('title-tag');
    add_theme_support('post-thumbnails');
    add_theme_support('align-wide');
    add_theme_support('custom-units');
    
    // Editor styles
    add_editor_style('assets/css/editor-style.css');
    
    // Load translations
    load_theme_textdomain('staynalive', STAYNALIVE_DIR . '/languages');
}
add_action('after_setup_theme', 'staynalive_setup');

/**
 * Enqueue scripts and styles
 */
function staynalive_scripts() {
    // Styles
    $styles = array(
        'header', 'footer', 'blog', 'single', 'page',
        '404', 'archive', 'comments', 'front-page',
        'search', 'sidebar', 'no-results', 'search-results'
    );
    
    foreach ($styles as $style) {
        wp_enqueue_style(
            "sna-{$style}-styles",
            STAYNALIVE_URI . "/assets/css/{$style}.css",
            array(),
            STAYNALIVE_VERSION
        );
    }
    
    // Scripts
    wp_enqueue_script(
        'staynalive-navigation',
        STAYNALIVE_URI . '/assets/js/navigation.js',
        array(),
        STAYNALIVE_VERSION,
        true
    );
}
add_action('wp_enqueue_scripts', 'staynalive_scripts');

/**
 * Register block styles
 */
function staynalive_register_block_styles() {
    $styles = array(
        'core/button' => array(
            'outline' => __('Outline', 'staynalive')
        ),
        'core/group' => array(
            'card' => __('Card', 'staynalive'),
            'glass' => __('Glass', 'staynalive')
        )
    );
    
    foreach ($styles as $block_name => $block_styles) {
        foreach ($block_styles as $style_name => $style_label) {
            register_block_style($block_name, array(
                'name' => $style_name,
                'label' => $style_label
            ));
        }
    }
}
add_action('init', 'staynalive_register_block_styles');

/**
 * Disable core block patterns
 */
function staynalive_disable_core_patterns() {
    remove_theme_support('core-block-patterns');
}
add_action('after_setup_theme', 'staynalive_disable_core_patterns');

/**
 * Register widget areas
 */
function staynalive_widgets_init() {
    register_sidebar(array(
        'name' => __('About Jesse', 'staynalive'),
        'id' => 'about-jesse-widget',
        'description' => __('Add widgets here to appear in the About Jesse section.', 'staynalive'),
        'before_widget' => '<div id="%1$s" class="widget %2$s">',
        'after_widget' => '</div>',
        'before_title' => '<h2 class="widget-title">',
        'after_title' => '</h2>',
    ));
}
add_action('widgets_init', 'staynalive_widgets_init'); 