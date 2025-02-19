<?php
/**
 * Plugin Name: Stay N Alive Companion
 * Plugin URI: https://staynalive.com
 * Description: Required functionality for the Stay N Alive theme
 * Version: 1.0.0
 * Author: Jesse Stay
 * Author URI: https://staynalive.com
 * License: GPL-2.0+
 * License URI: http://www.gnu.org/licenses/gpl-2.0.txt
 * Text Domain: stay-n-alive-companion
 */

// Exit if accessed directly
if (!defined('ABSPATH')) {
    exit;
}

// Move all plugin functionality here
require_once plugin_dir_path(__FILE__) . 'includes/performance.php';
require_once plugin_dir_path(__FILE__) . 'includes/security.php';
require_once plugin_dir_path(__FILE__) . 'includes/social-feeds.php'; 