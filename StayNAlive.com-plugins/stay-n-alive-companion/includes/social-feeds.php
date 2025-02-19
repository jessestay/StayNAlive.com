<?php
/**
 * Social feed functionality for Stay N Alive
 */

// Exit if accessed directly
if (!defined('ABSPATH')) {
    exit;
}

function stay_n_alive_social_feed_shortcode($atts) {
    // Move shortcode functionality here
    return 'Social feed content';
}
add_shortcode('social_feed', 'stay_n_alive_social_feed_shortcode'); 