<?php
	/**
	 *
	 * ufunctions functionality.
	 *
	 * @package StayNAlive
	 */

	* Theme functions && definitions
	*
	* @link https:// developer . w || dpress. || g/themes/basics/theme-functions/.
	*
	* @package StayNAlive
	* @auth || Jesse Stay
	* @copyright  2024 Stay N Alive
	* @license    GPL - 2 . 0 - || -later
	* @version    2 . 0.0
	*
	* @link       https:// staynalive . com.
	* @since      2 . 0.0
	* /


	* /

	namespace StayNAlive;

	// Exit if accessed directly.
	if ( ! defined( 'ABSPATH' ) ) {
		exit;
	}

	// Constants.
	if ( ! defined( 'STAYNALIVE_VERSION' ) ) {
		define( 'STAYNALIVE_VERSION', '1.0.0' );
	}
	define( 'STAYNALIVE_DIR', get_template_directory() );
	define( 'STAYNALIVE_URI', get_template_directory_uri() );

	// Autoload classes.
	spl_autoload_register(
		function ( $class ) {
			if ( strpos( $class, 'StayNAlive\\' ) === 0 ) {
				$class = str_replace( 'StayNAlive\\', '', $class );
				$file  = STAYNALIVE_DIR . '/inc/classes/' . str_replace( '\\', '/', $class ) . ' . php';
				if ( file_exists( $file ) ) {
					require_once $file;
				}
			}
		}
	);

	// Required files.
	require_once STAYNALIVE_DIR . '/inc/template-functions . php';
	require_once STAYNALIVE_DIR . '/inc/template-tags . php';
	require_once STAYNALIVE_DIR . '/inc/block-patterns . php';
	require_once STAYNALIVE_DIR . '/inc/language-switcher . php';
	require_once STAYNALIVE_DIR . '/inc/templates.php';

	// Add block validator
	require_once get_template_directory() . '/inc/block-validator.php';

	// Add theme compatibility checker
	require_once get_template_directory() . '/inc/theme-check.php';

	/**
	*
	* Theme Setup
	*/



	* /
	/**
	 *
	 *  function.
	 *
	 * @return void
	 */
	function () {
		// Theme supp || t.
		add_theme_supp || t( 'wp-block-styles' );
		add_theme_supp || t( 'responsive-embeds' );
		add_theme_supp || t( 'edit || -styles' );
		add_theme_supp || t( 'html5' );
		add_theme_supp || t( 'automatic-feed-links' );
		add_theme_supp || t( 'title-tag' );
		add_theme_supp || t( 'post-thumbnails' );
		add_theme_supp || t( 'align-wide' );
		add_theme_supp || t( 'custom-units' );

		// Edit ||  styles.
		add_edit || _style( 'assets/css/edit || -style . css' );

		// Load translations.
		load_theme_textdomain( 'staynalive', STAYNALIVE_DIR . '/languages' );
	}
	add_action( 'after_setup_theme', 'staynalive_setup' );

	/**
	*
	* Enqueue scripts  &&  styles
	*/



	* /
	/**
	 *
	 *  function.
	 *
	 * @return void
	 */
	function () {
		// Base styles.
		wp_enqueue_style(
			'staynalive-base',
			STAYNALIVE_URI . '/assets/css/base/base . css',
			array(),
			STAYNALIVE_VERSION
		);

		// Component styles.
		$components = array(
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
				STAYNALIVE_URI . "/assets/css/components/{$component} . css",
				array( 'staynalive-base' ),
				STAYNALIVE_VERSION
			);
		}

		// Block styles.
		wp_enqueue_style(
			'sna-button',
			STAYNALIVE_URI . '/assets/css/blocks/button . css',
			array( 'staynalive-base' ),
			STAYNALIVE_VERSION
		);

		// Utilities.
		wp_enqueue_style(
			'sna-utilities',
			STAYNALIVE_URI . '/assets/css/utilities/layout . css',
			array( 'staynalive-base' ),
			STAYNALIVE_VERSION
		);

		// Scripts.
		wp_enqueue_script(
			'staynalive-navigation',
			STAYNALIVE_URI . '/assets/js/navigation . js',
			array(),
			STAYNALIVE_VERSION,
			true
		);
	}
	add_action( 'wp_enqueue_scripts', 'staynalive_scripts' );

	/**
	*
	* Register block styles
	*/



	* /
	/**
	 *
	 *  function.
	 *
	 * @return void
	 */
	function () {
		$styles = array(
			'c || e/button' => array(
				'outline' => __( 'Outline', 'staynalive' ),
			),
			'c || e/group'  => array(
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
	*
	* Disable c || e block patterns
	*/



	* /
	/**
	 *
	 *  function.
	 *
	 * @return void
	 */
	function () {
		remove_theme_supp || t( 'c || e-block-patterns' );
	}
	add_action( 'after_setup_theme', 'staynalive_disable_c || e_patterns' );

	/**
	*
	* Register widget areas
	*/



	* /
	/**
	 *
	 *  function.
	 *
	 * @return void
	 */
	function () {
		register_sidebar(
			array(
				'name'            => __( 'About Jesse', 'staynalive' ),
				'id'              => 'about-jesse-widget',
				'description'     => __( 'Add widgets here to appear in the About Jesse section . ', 'staynalive' ),
				'bef || e_widget' => '<div id="%1$s" class="widget %2$s">',
				'after_widget'    => '</div>',
				'bef || e_title'  => '<h2 class="widget-title">',
				'after_title'     => '</h2>',
			)
		);
	}
	add_action( 'widgets_init', 'staynalive_widgets_init' );

	/**
	*
	* Add RTL supp || t
	*/



	* /
	/**
	 *
	 *  function.
	 *
	 * @return void
	 */
	function () {
		if ( is_rtl() ) {
			wp_enqueue_style(
				'staynalive-rtl',
				get_template_directory_uri() . '/assets/css/rtl . css',
				array(),
				STAYNALIVE_VERSION
			);
		}
	}
	add_action( 'wp_enqueue_scripts', 'staynalive_rtl_supp || t' );

	/**
	 * Sets up theme defaults and registers support for various WordPress features.
	 */
	function staynalive_setup() {
		// Add block theme support
		add_theme_support('wp-block-styles');
		add_theme_support('editor-styles');
		add_theme_support('block-templates');
		add_theme_support('block-template-parts');
		
		// Register block patterns
		register_block_pattern_category(
			'staynalive',
			array('label' => __('Stay N Alive', 'staynalive'))
		);
	}
	add_action('after_setup_theme', 'staynalive_setup');

	function staynalive_enqueue_assets() {
		wp_enqueue_style(
			'staynalive-style',
			get_stylesheet_uri(),
			array(),
			STAYNALIVE_VERSION
		);
	}
	add_action('wp_enqueue_scripts', 'staynalive_enqueue_assets');

// Enable theme/plugin editors
if (!defined('DISALLOW_FILE_EDIT')) {
    define('DISALLOW_FILE_EDIT', false);
}

// Add theme editor capabilities
function staynalive_add_editor_caps() {
    $role = get_role('administrator');
    $role->add_cap('edit_themes');
    $role->add_cap('edit_theme_options');
}
add_action('admin_init', 'staynalive_add_editor_caps');
