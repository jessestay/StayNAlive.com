<?php
/**
 * Performance optimizations
 *
 * @package StayNAlive
 */

namespace StayNAlive\Performance;

// Remove unnecessary meta tags
remove_action('wp_head', 'wlwmanifest_link');
remove_action('wp_head', 'rsd_link');
remove_action('wp_head', 'wp_shortlink_wp_head');

// Disable emoji scripts
add_action('init', function() {
    remove_action('wp_head', 'print_emoji_detection_script', 7);
    remove_action('admin_print_scripts', 'print_emoji_detection_script');
    remove_action('wp_print_styles', 'print_emoji_styles');
    remove_action('admin_print_styles', 'print_emoji_styles');
    remove_filter('the_content_feed', 'wp_staticize_emoji');
    remove_filter('comment_text_rss', 'wp_staticize_emoji');
    remove_filter('wp_mail', 'wp_staticize_emoji_for_email');
});

// Add preload for critical assets
add_action('wp_head', function() {
    echo '<link rel="preload" href="' . get_theme_file_uri('assets/css/base/base.css') . '" as="style">';
    echo '<link rel="preload" href="' . get_theme_file_uri('assets/js/animations.js') . '" as="script">';
}, 1);
?>
