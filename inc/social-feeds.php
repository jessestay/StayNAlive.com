<?php
/**
 * Social feed functionality
 *
 * @package StayNAlive
 */

// Exit if accessed directly
if (!defined('ABSPATH')) {
    exit;
}

/**
 * Get social feed content
 */
function staynalive_get_social_feed($type = 'twitter', $count = 5) {
    // Social feed implementation
    $output = '';
    
    switch ($type) {
        case 'twitter':
            // Twitter feed implementation
            break;
            
        case 'instagram':
            // Instagram feed implementation
            break;
    }
    
    return $output;
}
