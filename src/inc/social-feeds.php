<?php
/**
 * Social media feed integration
 *
 * @package Stay_N_Alive
 */

namespace StayNAlive\SocialFeeds;

if (!defined('ABSPATH')) {
    exit; // Exit if accessed directly
}

/**
 * Register REST API endpoints for social feeds
 */
function register_feed_endpoints() {
    register_rest_route('staynalive/v1', '/instagram-feed', array(
        'methods'  => 'GET',
        'callback' => __NAMESPACE__ . '\get_instagram_feed',
        'permission_callback' => '__return_true',
    ));

    register_rest_route('staynalive/v1', '/twitter-feed', array(
        'methods'  => 'GET',
        'callback' => __NAMESPACE__ . '\get_twitter_feed',
        'permission_callback' => '__return_true',
    ));
}
add_action('rest_api_init', __NAMESPACE__ . '\register_feed_endpoints');

/**
 * Get Instagram feed
 */
function get_instagram_feed() {
    $cache_key = 'staynalive_instagram_feed';
    $cache_group = 'staynalive_social';
    $cache_time = 3600; // 1 hour

    $feed = wp_cache_get($cache_key, $cache_group);
    if (false === $feed) {
        // Fetch feed here
        $feed = array(); // Placeholder for actual API call
        wp_cache_set($cache_key, $feed, $cache_group, $cache_time);
    }

    return rest_ensure_response($feed);
}

/**
 * Get Twitter feed
 */
function get_twitter_feed() {
    $cache_key = 'staynalive_twitter_feed';
    $cache_group = 'staynalive_social';
    $cache_time = 3600; // 1 hour

    $feed = wp_cache_get($cache_key, $cache_group);
    if (false === $feed) {
        // Fetch feed here
        $feed = array(); // Placeholder for actual API call
        wp_cache_set($cache_key, $feed, $cache_group, $cache_time);
    }

    return rest_ensure_response($feed);
} 