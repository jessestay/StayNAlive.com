<?php
/**
 * Performance optimizations for the Stay N Alive theme
 */

// Only theme-specific performance optimizations here
function stay_n_alive_theme_performance() {
    // Add theme-specific performance code here
    add_theme_support('html5', array(
        'search-form',
        'comment-form',
        'comment-list',
        'gallery',
        'caption',
        'style',
        'script'
    ));
}
add_action('after_setup_theme', 'stay_n_alive_theme_performance'); 