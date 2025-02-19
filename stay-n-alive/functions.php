<?php
/**
 * Stay N Alive functions and definitions
 *
 * @package StayNAlive
 */

if ( ! defined( 'ABSPATH' ) ) {
    exit; // Exit if accessed directly
}

// Define theme constants
define( 'STAY_N_ALIVE_VERSION', '1.0.0' );
define( 'STAY_N_ALIVE_DIR', get_template_directory() );
define( 'STAY_N_ALIVE_URI', get_template_directory_uri() );

// Require theme setup file
require_once STAY_N_ALIVE_DIR . '/inc/theme-setup.php';

// Require other core files
require_once STAY_N_ALIVE_DIR . '/inc/security.php';
require_once STAY_N_ALIVE_DIR . '/inc/performance.php';
require_once STAY_N_ALIVE_DIR . '/inc/social-feeds.php';
require_once STAY_N_ALIVE_DIR . '/inc/template-loader.php';
require_once STAY_N_ALIVE_DIR . '/inc/block-patterns.php';

/**
 * Theme setup
 */
function stay_n_alive_setup() {
    // Add theme support
    add_theme_support( 'wp-block-styles' );
    add_theme_support( 'editor-styles' );
    add_theme_support( 'responsive-embeds' );
    add_theme_support( 'align-wide' );
    add_theme_support( 'custom-spacing' );
    
    // Add editor styles
    add_editor_style( array(
        'assets/css/editor-style.css',
        'assets/css/base/base.css',
        'assets/css/components/header.css',
        'assets/css/components/footer.css'
    ) );
    
    // Register nav menus
    register_nav_menus( array(
        'primary' => __( 'Primary Menu', 'stay-n-alive' ),
        'footer'  => __( 'Footer Menu', 'stay-n-alive' ),
    ) );
}
add_action( 'after_setup_theme', 'stay_n_alive_setup' );

/**
 * Enqueue scripts and styles
 */
function stay_n_alive_scripts() {
    // Styles
    wp_enqueue_style(
        'stay-n-alive-style',
        get_stylesheet_uri(),
        array(),
        STAY_N_ALIVE_VERSION
    );
    
    // Scripts
    wp_enqueue_script(
        'stay-n-alive-animations',
        STAY_N_ALIVE_URI . '/assets/js/animations.js',
        array(),
        STAY_N_ALIVE_VERSION,
        true
    );
}
add_action( 'wp_enqueue_scripts', 'stay_n_alive_scripts' ); 