<?php
/**
 * Performance optimizations
 *
 * @package Stay_N_Alive
 */

namespace StayNAlive\Performance;

if (!defined('ABSPATH')) {
    exit; // Exit if accessed directly
}

/**
 * Remove unnecessary meta tags
 */
remove_action('wp_head', 'wp_generator');
remove_action('wp_head', 'wlwmanifest_link');
remove_action('wp_head', 'rsd_link');
remove_action('wp_head', 'wp_shortlink_wp_head');

/**
 * Disable emoji support if not needed
 */
function disable_emojis() {
    remove_action('wp_head', 'print_emoji_detection_script', 7);
    remove_action('admin_print_scripts', 'print_emoji_detection_script');
    remove_action('wp_print_styles', 'print_emoji_styles');
    remove_action('admin_print_styles', 'print_emoji_styles');
    remove_filter('the_content_feed', 'wp_staticize_emoji');
    remove_filter('comment_text_rss', 'wp_staticize_emoji');
    remove_filter('wp_mail', 'wp_staticize_emoji_for_email');
}
add_action('init', __NAMESPACE__ . '\disable_emojis');

/**
 * Optimize script loading
 */
function optimize_script_loading() {
    // Add defer to scripts
    function add_defer_attribute($tag, $handle) {
        if ('stay-n-alive-animations' === $handle) {
            return str_replace(' src', ' defer src', $tag);
        }
        return $tag;
    }
    add_filter('script_loader_tag', __NAMESPACE__ . '\add_defer_attribute', 10, 2);
}
add_action('wp_enqueue_scripts', __NAMESPACE__ . '\optimize_script_loading'); 