<?php
/**
 * Security Class
 *
 * @package StayNAlive
 */

if (!defined('ABSPATH')) {
    exit;
}

class Stay_N_Alive_Security {
    public function __construct() {
        add_action('init', array($this, 'security_headers'));
        add_filter('xmlrpc_enabled', '__return_false');
    }

    public function security_headers() {
        header('X-Content-Type-Options: nosniff');
        header('X-Frame-Options: SAMEORIGIN');
        header('X-XSS-Protection: 1; mode=block');
    }
}

new Stay_N_Alive_Security(); 