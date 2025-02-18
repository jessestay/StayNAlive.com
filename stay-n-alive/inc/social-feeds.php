<?php
/**
 * Social Media Feed Integration
 *
 * @package StayNAlive
 */

namespace StayNAlive\SocialFeeds;

// Register REST API endpoints
add_action('rest_api_init', function() {
    register_rest_route('staynalive/v1', '/instagram-feed', [
        'methods' => 'GET',
        'callback' => __NAMESPACE__ . '\get_instagram_feed',
        'permission_callback' => '__return_true'
    ]);
    
    register_rest_route('staynalive/v1', '/tiktok-feed', [
        'methods' => 'GET',
        'callback' => __NAMESPACE__ . '\get_tiktok_feed',
        'permission_callback' => '__return_true'
    ]);
    
    register_rest_route('staynalive/v1', '/youtube-feed', [
        'methods' => 'GET',
        'callback' => __NAMESPACE__ . '\get_youtube_feed',
        'permission_callback' => '__return_true'
    ]);
});

function get_instagram_feed() {
    $options = get_option('staynalive_social_media', []);
    $token = $options['instagram_token'] ?? '';
    
    if (empty($token)) {
        return new \WP_Error('missing_token', 'Instagram token is required');
    }
    
    $cache_key = 'instagram_feed_' . md5($token);
    $cached = get_transient($cache_key);
    
    if (false !== $cached) {
        return $cached;
    }
    
    $response = wp_remote_get(
        "https://graph.instagram.com/me/media?fields=id,caption,media_type,media_url,thumbnail_url,permalink&access_token={$token}"
    );
    
    if (is_wp_error($response)) {
        return $response;
    }
    
    $data = json_decode(wp_remote_retrieve_body($response), true);
    set_transient($cache_key, $data, HOUR_IN_SECONDS);
    
    return $data;
}

function get_youtube_feed() {
    $options = get_option('staynalive_social_media', []);
    $api_key = $options['youtube_api_key'] ?? '';
    $channel_id = $options['youtube_channel_id'] ?? '';
    
    if (empty($api_key) || empty($channel_id)) {
        return new \WP_Error('missing_config', 'YouTube API key and channel ID are required');
    }
    
    $cache_key = 'youtube_feed_' . md5($api_key . $channel_id);
    $cached = get_transient($cache_key);
    
    if (false !== $cached) {
        return $cached;
    }
    
    $response = wp_remote_get(
        "https://www.googleapis.com/youtube/v3/search?part=snippet&channelId={$channel_id}&maxResults=10&order=date&type=video&key={$api_key}"
    );
    
    if (is_wp_error($response)) {
        return $response;
    }
    
    $data = json_decode(wp_remote_retrieve_body($response), true);
    set_transient($cache_key, $data, HOUR_IN_SECONDS);
    
    return $data;
}
