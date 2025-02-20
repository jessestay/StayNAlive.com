<?php
/**
 * Theme setup class
 *
 * @package StayNAlive
 */

if ( ! defined( 'ABSPATH' ) ) {
    exit;
}

class Stay_N_Alive_Theme_Setup {
    /**
     * Constructor
     */
    public function __construct() {
        add_action( 'after_setup_theme', array( $this, 'setup' ) );
        add_action( 'init', array( $this, 'register_menus' ) );
        add_action( 'wp_enqueue_scripts', array( $this, 'enqueue_assets' ) );
    }

    /**
     * Sets up theme defaults and registers support for various WordPress features
     */
    public function setup() {
        // Add default posts and comments RSS feed links to head
        add_theme_support( 'automatic-feed-links' );

        // Let WordPress manage the document title
        add_theme_support( 'title-tag' );

        // Enable support for Post Thumbnails
        add_theme_support( 'post-thumbnails' );

        // Switch default core markup to output valid HTML5
        add_theme_support( 'html5', array(
            'search-form',
            'comment-form',
            'comment-list',
            'gallery',
            'caption',
            'style',
            'script',
        ) );

        // Add theme support for selective refresh for widgets
        add_theme_support( 'customize-selective-refresh-widgets' );

        // Add support for Block Styles
        add_theme_support( 'wp-block-styles' );

        // Add support for full and wide align images
        add_theme_support( 'align-wide' );

        // Add support for responsive embedded content
        add_theme_support( 'responsive-embeds' );
    }

    /**
     * Register navigation menus
     */
    public function register_menus() {
        register_nav_menus( array(
            'primary' => esc_html__( 'Primary Menu', 'stay-n-alive' ),
            'footer'  => esc_html__( 'Footer Menu', 'stay-n-alive' ),
        ) );
    }

    /**
     * Enqueue scripts and styles
     */
    public function enqueue_assets() {
        // Enqueue styles
        wp_enqueue_style(
            'stay-n-alive-style',
            get_stylesheet_uri(),
            array(),
            wp_get_theme()->get( 'Version' )
        );

        // Enqueue scripts
        wp_enqueue_script(
            'stay-n-alive-navigation',
            get_template_directory_uri() . '/assets/js/navigation.js',
            array(),
            wp_get_theme()->get( 'Version' ),
            true
        );
    }
}

// Initialize the class
new Stay_N_Alive_Theme_Setup(); 