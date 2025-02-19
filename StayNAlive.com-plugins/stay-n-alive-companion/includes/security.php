<?php
/**
 * Security enhancements for Stay N Alive
 */

// Exit if accessed directly
if (!defined('ABSPATH')) {
    exit;
}

function stay_n_alive_companion_security() {
    remove_action('wp_head', 'wp_generator');
}
add_action('init', 'stay_n_alive_companion_security'); 