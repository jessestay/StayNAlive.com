<?php
/**
 * Security functions
 *
 * @package StayNAlive
 */

namespace StayNAlive\Security;

/**
 * Remove WordPress version from various locations
 */
function remove_version_info() {
    return '';
}
add_filter('the_generator', __NAMESPACE__ . '\remove_version_info');

/**
 * Disable XML-RPC
 */
add_filter('xmlrpc_enabled', '__return_false');

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
