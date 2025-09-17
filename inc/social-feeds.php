<?php
/**
 * Social feed features for the Stay N Alive theme
 */

// Only theme-specific social feed features here
function stay_n_alive_theme_social_feeds() {
    // Add theme-specific social feed code here
    add_theme_support('custom-logo');
}
add_action('after_setup_theme', 'stay_n_alive_theme_social_feeds'); 