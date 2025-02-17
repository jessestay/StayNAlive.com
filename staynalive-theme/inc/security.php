<?php
/**
 * Security enhancements
 *
 * @package StayNAlive
 */

namespace StayNAlive\Security;

// Disable file editing in WordPress admin
if (!defined('DISALLOW_FILE_EDIT')) {
    define('DISALLOW_FILE_EDIT', true);
}

// Remove WordPress version from sources
remove_action('wp_head', 'wp_generator');

// Add security headers
add_action('send_headers', function() {
    header('X-Content-Type-Options: nosniff');
    header('X-Frame-Options: SAMEORIGIN');
    header('X-XSS-Protection: 1; mode=block');
    header('Referrer-Policy: strict-origin-when-cross-origin');
});

// Sanitize SVG uploads
add_filter('wp_handle_upload_prefilter', function($file) {
    if ($file['type'] === 'image/svg+xml') {
        if (!sanitize_svg($file['tmp_name'])) {
            $file['error'] = 'Invalid SVG file';
        }
    }
    return $file;
});
