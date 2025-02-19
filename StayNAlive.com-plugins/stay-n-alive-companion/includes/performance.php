<?php
/**
 * Performance optimizations for Stay N Alive
 */

// Exit if accessed directly
if (!defined('ABSPATH')) {
    exit;
}

function stay_n_alive_companion_performance() {
    remove_action('wp_head', 'wp_shortlink_wp_head');
    remove_action('wp_head', 'wp_generator');
    remove_action('wp_head', 'rsd_link');
}
add_action('init', 'stay_n_alive_companion_performance'); 