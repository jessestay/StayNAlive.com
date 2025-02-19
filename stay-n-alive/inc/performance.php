<?php
/**
 * Performance optimizations
 *
 * @package StayNAlive
 */

namespace StayNAlive\Performance;

/**
 * Remove unnecessary emoji scripts
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
function optimize_scripts() {
    if (!is_admin()) {
        wp_deregister_script('wp-embed');
    }
}
add_action('wp_enqueue_scripts', __NAMESPACE__ . '\optimize_scripts', 100);
