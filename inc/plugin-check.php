<?php
/**
 * Plugin Name: Stay N Alive Companion
 * Plugin URI: https://staynalive.com
 * Description: Required functionality for the Stay N Alive theme
 * Version: 1.0.0
 * Author: Jesse Stay
 * Author URI: https://staynalive.com
 * License: GPL-2.0+
 * License URI: http://www.gnu.org/licenses/gpl-2.0.txt
 * Text Domain: stay-n-alive-companion
 */

// Exit if accessed directly
if (!defined('ABSPATH')) {
    exit;
}

/**
 * Performance optimizations
 */
function stay_n_alive_companion_performance() {
    remove_action('wp_head', 'wp_shortlink_wp_head');
    remove_action('wp_head', 'wp_generator');
    remove_action('wp_head', 'rsd_link');
}
add_action('init', 'stay_n_alive_companion_performance');

/**
 * Security enhancements
 */
function stay_n_alive_companion_security() {
    remove_action('wp_head', 'wp_generator');
}
add_action('init', 'stay_n_alive_companion_security');

/**
 * Social feed shortcode
 */
function stay_n_alive_social_feed_shortcode($atts) {
    // Move shortcode functionality here
    return 'Social feed content';
}
add_shortcode('social_feed', 'stay_n_alive_social_feed_shortcode'); 