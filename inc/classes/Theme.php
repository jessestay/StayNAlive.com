<?php
/**
 * Main theme class
 *
 * @package StayNAlive
 */

namespace StayNAlive;

/**
 * Theme setup and initialization
 */
class Theme {
	/**
	 * Instance of this class
	 *
	 * @var Theme
	 */
	private static $instance = null;

	/**
	 * Get singleton instance
	 *
	 * @return Theme Instance of theme class
	 */
	public static function get_instance() {
		if ( null === self::$instance ) {
			self::$instance = new self();
		}
		return self::$instance;
	}

	/**
	 * Constructor
	 */
	private function __construct() {
		$this->setup_hooks();
	}

	/**
	 * Set up theme hooks
	 */
	private function setup_hooks() {
		add_action( 'after_setup_theme', array( $this, 'setup' ) );
		add_action( 'wp_enqueue_scripts', array( $this, 'enqueue_scripts' ) );
		add_action( 'init', array( $this, 'register_block_styles' ) );
	}

	/**
	 * Set up theme defaults and register support for various WordPress features.
	 */
	public function setup() {
		// Theme setup code.
	}

	/**
	 * Enqueue scripts and styles.
	 */
	public function enqueue_scripts() {
		// Enqueue scripts code.
	}

	/**
	 * Register block styles.
	 */
	public function register_block_styles() {
		// Block styles registration code.
	}
}
