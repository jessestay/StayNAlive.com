<?php
/**
 * Social feed functionality
 *
 * @package StayNAlive
 */

namespace StayNAlive\SocialFeeds;

// Register REST API endpoints.
add_action(
	'rest_api_init',
	function () {
		register_rest_route(
			'staynalive/v1',
			'/instagram-feed',
			array(
				'methods'             => 'GET',
				'callback'            => __NAMESPACE__ . '\get_instagram_feed',
				'permission_callback' => '__return_true',
			)
		);

		register_rest_route(
			'staynalive/v1',
			'/tiktok-feed',
			array(
				'methods'             => 'GET',
				'callback'            => __NAMESPACE__ . '\get_tiktok_feed',
				'permission_callback' => '__return_true',
			)
		);

		register_rest_route(
			'staynalive/v1',
			'/youtube-feed',
			array(
				'methods'             => 'GET',
				'callback'            => __NAMESPACE__ . '\get_youtube_feed',
				'permission_callback' => '__return_true',
			)
		);

		register_rest_route(
			'staynalive/v1',
			'/twitter-feed',
			array(
				'methods'             => 'GET',
				'callback'            => __NAMESPACE__ . '\get_twitter_feed',
				'permission_callback' => '__return_true',
			)
		);
	}
);

// Add social media settings to theme.
add_action(
	'admin_init',
	function () {
		register_setting(
			'reading',
			'staynalive_social_media',
			array(
				'type'    => 'object',
				'default' => array(),
			)
		);

		add_settings_section(
			'staynalive_social_media_section',
			'Social Media Integration',
			'__return_false',
			'reading'
		);

		$fields = array(
			'instagram_token'      => 'Instagram Access Token',
			'tiktok_token'         => 'TikTok Access Token',
			'youtube_api_key'      => 'YouTube API Key',
			'twitter_bearer_token' => 'Twitter Bearer Token',
		);

		foreach ( $fields as $id => $label ) {
			add_settings_field(
				$id,
				$label,
				function () use ( $id ) {
					$options = get_option( 'staynalive_social_media', array() );
					printf(
						'<input type="text" id="%s" name="staynalive_social_media[%s]" value="%s" class="regular-text">',
						esc_attr( $id ),
						esc_attr( $id ),
						esc_attr( $options[ $id ] ?? '' )
					);
				},
				'reading',
				'staynalive_social_media_section'
			);
		}
	}
);

// Helper functions for feed retrieval.
function get_instagram_feed() {
	$options = get_option( 'staynalive_social_media', array() );
	$token   = $options['instagram_token'] ?? '';

	if ( empty( $token ) ) {
		return new \WP_Error( 'missing_token', 'Instagram token is required' );
	}

	// Cache key based on token
	$cache_key = 'instagram_feed_' . md5( $token );
	$cached    = get_transient( $cache_key );

	if ( $cached !== false ) {
		return $cached;
	}

	// Fetch and process feed
	$response = wp_remote_get( "https://graph.instagram.com/me/media?fields=id,caption,media_type,media_url,thumbnail_url,permalink&access_token={$token}" );

	if ( is_wp_error( $response ) ) {
		return $response;
	}

	$data = json_decode( wp_remote_retrieve_body( $response ), true );
	set_transient( $cache_key, $data, HOUR_IN_SECONDS );

	return $data;
}

/**
 * Get YouTube feed data
 *
 * @return array|WP_Error Feed data or error object
 */
function get_youtube_feed() {
	$options    = get_option( 'staynalive_social_media', array() );
	$api_key    = $options['youtube_api_key'] ?? '';
	$channel_id = $options['youtube_channel_id'] ?? '';

	if ( empty( $api_key ) || empty( $channel_id ) ) {
		return new \WP_Error( 'missing_config', 'YouTube API key and channel ID are required' );
	}

	$cache_key = 'youtube_feed_' . md5( $api_key . $channel_id );
	$cached    = get_transient( $cache_key );

	if ( $cached !== false ) {
		return $cached;
	}

	$response = wp_remote_get(
		"https://www.googleapis.com/youtube/v3/search?part=snippet&channelId={$channel_id}&maxResults=10&order=date&type=video&key={$api_key}"
	);

	if ( is_wp_error( $response ) ) {
		return $response;
	}

	$data   = json_decode( wp_remote_retrieve_body( $response ), true );
	$videos = array_map(
		function ( $item ) {
			return array(
				'id'          => $item['id']['videoId'],
				'title'       => $item['snippet']['title'],
				'description' => $item['snippet']['description'],
				'thumbnail'   => $item['snippet']['thumbnails']['high']['url'],
				'link'        => "https://www.youtube.com/watch?v={$item['id']['videoId']}",
			);
		},
		$data['items'] ?? array()
	);

	set_transient( $cache_key, $videos, HOUR_IN_SECONDS );
	return $videos;
}

/**
 * Retrieve Twitter feed data
 *
 * @return array|WP_Error Feed data or error object
 */
function get_twitter_feed() {
	$options      = get_option( 'staynalive_social_media', array() );
	$bearer_token = $options['twitter_bearer_token'] ?? '';
	$username     = $options['twitter_username'] ?? '';

	if ( empty( $bearer_token ) || empty( $username ) ) {
		return new \WP_Error( 'missing_config', 'Twitter bearer token and username are required' );
	}

	$cache_key = 'twitter_feed_' . md5( $bearer_token . $username );
	$cached    = get_transient( $cache_key );

	if ( $cached !== false ) {
		return $cached;
	}

	$response = wp_remote_get(
		"https://api.twitter.com/2/users/by/username/{$username}/tweets?expansions=attachments.media_keys&media.fields=url,preview_image_url",
		array(
			'headers' => array(
				'Authorization' => "Bearer {$bearer_token}",
			),
		)
	);

	if ( is_wp_error( $response ) ) {
		return $response;
	}

	$data = json_decode( wp_remote_retrieve_body( $response ), true );
	set_transient( $cache_key, $data['data'], HOUR_IN_SECONDS );
	return $data['data'];
}

// Similar functions for other platforms...

add_filter( 'xmlrpc_enabled', '__return_false' );

if ( ! defined( 'DISALLOW_FILE_EDIT' ) ) {

/**
 * Get social feed items.
 *
 * @param string $feed_type Type of feed to retrieve.
 * @return array Array of feed items.
 */
function get_social_feed_items( $feed_type ) {
	$options = get_option( 'staynalive_social_media', array() );
	
	if ( 'instagram' === $feed_type ) {
		return get_instagram_feed();
	}
	
	if ( 'twitter' === $feed_type ) {
		return get_twitter_feed();
	}
	
	return array();
}

/**
 * Process feed data.
 *
 * @param array $data Raw feed data.
 * @return array Processed feed data.
 */
function process_feed_data($data) {
	if (!is_array($data)) {
		return array();
	}
	
	return array_map(
		function($item) {
			return array(
				'id'      => $item['id'] ?? '',
				'content' => $item['content'] ?? '',
				'link'    => $item['link'] ?? ''
			);
		},
		$data
	);
}
