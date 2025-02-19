<?php
/**
 * Plugin Name: StayNAlive Functionality
 * Plugin URI: https://staynalive.com
 * Description: Core functionality for the StayNAlive theme
 * Version: 1.0.0
 * Author: Jesse Stay
 * Author URI: https://staynalive.com
 * License: GPL-2.0+
 * License URI: http://www.gnu.org/licenses/gpl-2.0.txt
 * Text Domain: staynalive-functionality
 */

// Exit if accessed directly
if (!defined('ABSPATH')) {
    exit;
}

class StayNAlive_Functionality {
    /**
     * Initialize the plugin
     */
    public function __construct() {
        add_action('init', [$this, 'init']);
    }

    /**
     * Initialize plugin functionality
     */
    public function init() {
        // Remove unnecessary header items
        $this->cleanup_wp_head();
        
        // Register shortcodes
        $this->register_shortcodes();
    }

    /**
     * Clean up wp_head output
     */
    private function cleanup_wp_head() {
        // Remove WordPress version number
        remove_action('wp_head', 'wp_generator');
        
        // Remove Windows Live Writer manifest link
        remove_action('wp_head', 'wlwmanifest_link');
        
        // Remove RSD link
        remove_action('wp_head', 'rsd_link');
        
        // Remove shortlink
        remove_action('wp_head', 'wp_shortlink_wp_head');
    }

    /**
     * Register shortcodes
     */
    private function register_shortcodes() {
        add_shortcode('social_feed', [$this, 'social_feed_shortcode']);
    }

    /**
     * Social feed shortcode callback
     */
    public function social_feed_shortcode($atts) {
        $atts = shortcode_atts([
            'type' => 'twitter',
            'count' => 5
        ], $atts);

        ob_start();
        ?>
        <div class="social-feed social-feed-<?php echo esc_attr($atts['type']); ?>">
            <?php 
            // Move social feed logic here from theme
            if (function_exists('staynalive_get_social_feed')) {
                echo staynalive_get_social_feed($atts['type'], $atts['count']);
            }
            ?>
        </div>
        <?php
        return ob_get_clean();
    }
}

// Initialize plugin
new StayNAlive_Functionality(); 