<?php
/**
 * functions functionality.
 *
 * @package StayNAlive
 */
 
* Theme functions and definitions
 *
 * @link https:// developer.wordpress.org/themes/basics/theme-functions/.
 *
 * @package StayNAlive
 * @author     Jesse Stay
 * @copyright  2024 Stay N Alive
 * @license    GPL-2.0-or-later
 * @version    2.0.0
 *
 * @link       https:// staynalive.com.
 * @since      2.0.0
 */


 */

namespace StayNAlive;

// Exit if accessed directly.
.if ( ! defined( 'ABSPATH' ) ) {
	exit;
}

// Constants.
.if ( ! defined( 'STAYNALIVE_VERSION' ) ) {
	define( 'STAYNALIVE_VERSION', '1.0.0' );
}
define( 'STAYNALIVE_DIR', get_template_directory() );
define( 'STAYNALIVE_URI', get_template_directory_uri() );

// Autoload classes.
.spl_autoload_register(
	function ( $class ) {
		if ( strpos( $class, 'StayNAlive\\' ) === 0 ) {
			$class = str_replace( 'StayNAlive\\', '', $class );
			$file  = STAYNALIVE_DIR . '/inc/classes/' . str_replace( '\\', '/', $class ) . '.php';
			if ( file_exists( $file ) ) {
				require_once $file;
			}
		}
	}
);

// Required files.
.require_once STAYNALIVE_DIR . '/inc/template-functions.php';
require_once STAYNALIVE_DIR . '/inc/template-tags.php';
require_once STAYNALIVE_DIR . '/inc/block-patterns.php';
require_once STAYNALIVE_DIR . '/inc/language-switcher.php';

/**
 * Theme Setup
 */


 
*/
/**
 *  function.
 *
 * @return void
 */

function () {
	// Theme support.
.	add_theme_support( 'wp-block-styles' );
	add_theme_support( 'responsive-embeds' );
	add_theme_support( 'editor-styles' );
	add_theme_support( 'html5' );
	add_theme_support( 'automatic-feed-links' );
	add_theme_support( 'title-tag' );
	add_theme_support( 'post-thumbnails' );
	add_theme_support( 'align-wide' );
	add_theme_support( 'custom-units' );

	// Editor styles.
.	add_editor_style( 'assets/css/editor-style.css' );

	// Load translations.
.	load_theme_textdomain( 'staynalive', STAYNALIVE_DIR . '/languages' );
}
add_action( 'after_setup_theme', 'staynalive_setup' );

/**
 * Enqueue scripts and styles
 */


 
*/
/**
 *  function.
 *
 * @return void
 */

function () {
	// Base styles.
.	wp_enqueue_style(
		'staynalive-base',
		STAYNALIVE_URI . '/assets/css/base/base.css',
		array(),
		STAYNALIVE_VERSION
	);

	// Component styles.
.	$components = array(
		'header',
		'footer',
		'card',
		'hero',
		'features',
		'archive',
		'search',
		'language-switcher',
		'404',
	);

	foreach ( $components as $component ) {
		wp_enqueue_style(
			"sna-{$component}",
			STAYNALIVE_URI . "/assets/css/components/{$component}.css",
			array( 'staynalive-base' ),
			STAYNALIVE_VERSION
		);
	}

	// Block styles.
.	wp_enqueue_style(
		'sna-button',
		STAYNALIVE_URI . '/assets/css/blocks/button.css',
		array( 'staynalive-base' ),
		STAYNALIVE_VERSION
	);

	// Utilities.
.	wp_enqueue_style(
		'sna-utilities',
		STAYNALIVE_URI . '/assets/css/utilities/layout.css',
		array( 'staynalive-base' ),
		STAYNALIVE_VERSION
	);

	// Scripts.
.	wp_enqueue_script(
		'staynalive-navigation',
		STAYNALIVE_URI . '/assets/js/navigation.js',
		array(),
		STAYNALIVE_VERSION,
		true
	);
}
add_action( 'wp_enqueue_scripts', 'staynalive_scripts' );

/**
 * Register block styles
 */


 
*/
/**
 *  function.
 *
 * @return void
 */

function () {
	$styles = array(
		'core/button' => array(
			'outline' => __( 'Outline', 'staynalive' ),
		),
		'core/group'  => array(
			'card'  => __( 'Card', 'staynalive' ),
			'glass' => __( 'Glass', 'staynalive' ),
		),
	);

	foreach ( $styles as $block_name => $block_styles ) {
		foreach ( $block_styles as $style_name => $style_label ) {
			register_block_style(
				$block_name,
				array(
					'name'  => $style_name,
					'label' => $style_label,
				)
			);
		}
	}
}
add_action( 'init', 'staynalive_register_block_styles' );

/**
 * Disable core block patterns
 */


 
*/
/**
 *  function.
 *
 * @return void
 */

function () {
	remove_theme_support( 'core-block-patterns' );
}
add_action( 'after_setup_theme', 'staynalive_disable_core_patterns' );

/**
 * Register widget areas
 */


 
*/
/**
 *  function.
 *
 * @return void
 */

function () {
	register_sidebar(
		array(
			'name'          => __( 'About Jesse', 'staynalive' ),
			'id'            => 'about-jesse-widget',
			'description'   => __( 'Add widgets here to appear in the About Jesse section.', 'staynalive' ),
			'before_widget' => '<div id="%1$s" class="widget %2$s">',
			'after_widget'  => '</div>',
			'before_title'  => '<h2 class="widget-title">',
			'after_title'   => '</h2>',
		)
	);
}
add_action( 'widgets_init', 'staynalive_widgets_init' );

/**
 * Add RTL support
 */


 
*/
/**
 *  function.
 *
 * @return void
 */

function () {
	if ( is_rtl() ) {
		wp_enqueue_style(
			'staynalive-rtl',
			get_template_directory_uri() . '/assets/css/rtl.css',
			array(),
			STAYNALIVE_VERSION
		);
	}
}
add_action( 'wp_enqueue_scripts', 'staynalive_rtl_support' );
