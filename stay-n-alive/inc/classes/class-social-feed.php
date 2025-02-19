<?php
/**
 * Social Feed Class
 *
 * @package StayNAlive
 */

if (!defined('ABSPATH')) {
    exit;
}

class Stay_N_Alive_Social_Feed {
    public function __construct() {
        add_action('rest_api_init', array($this, 'register_endpoints'));
    }

    public function register_endpoints() {
        register_rest_route('staynalive/v1', '/instagram-feed', array(
            'methods' => 'GET',
            'callback' => array($this, 'get_instagram_feed'),
            'permission_callback' => '__return_true'
        ));
        
        register_rest_route('staynalive/v1', '/twitter-feed', array(
            'methods' => 'GET',
            'callback' => array($this, 'get_twitter_feed'),
            'permission_callback' => '__return_true'
        ));
    }
}

new Stay_N_Alive_Social_Feed(); 