<?php
/**
 * Security enhancements
 *
 * @package StayNAlive
 */

namespace StayNAlive\Security;

if (!defined('ABSPATH')) {
    exit; // Exit if accessed directly
}

/**
 * Disable XML-RPC
 */
add_filter('xmlrpc_enabled', '__return_false');

/**
 * Remove WordPress version from various locations
 */
remove_action('wp_head', 'wp_generator');

/**
 * Disable file editing in WordPress admin
 */
if (!defined('DISALLOW_FILE_EDIT')) {
    define('DISALLOW_FILE_EDIT', true);
}

/**
 * Disable user enumeration
 */
function disable_user_enumeration() {
    if (is_admin()) return;
    
    if (isset($_REQUEST['author']) && !current_user_can('list_users')) {
        wp_die('Author parameter is forbidden.');
    }
}
add_action('init', __NAMESPACE__ . '\disable_user_enumeration');

/**
 * Remove WordPress version from scripts and styles
 */
function remove_version_from_assets($src) {
    if (strpos($src, 'ver=')) {
        $src = remove_query_arg('ver', $src);
    }
    return $src;
}
add_filter('style_loader_src', __NAMESPACE__ . '\remove_version_from_assets');
add_filter('script_loader_src', __NAMESPACE__ . '\remove_version_from_assets');

// ... rest of security.php content ... 