<?php
/**
 * Security enhancements for the theme
 *
 * @package staynalive
 */
namespace StayNAlive;

// Disable XML-RPC functionality.
add_filter('xmlrpc_enabled', '__return_false');

// Remove WordPress version from head.
remove_action('wp_head', 'wp_generator');

// Disable file editing in admin.
if ( ! defined( 'DISALLOW_FILE_EDIT' ) ) {
	define( 'DISALLOW_FILE_EDIT', true );
}

// Add security headers
add_action(
	'send_headers',
	function () {
		header( 'X-Content-Type-Options: nosniff' );
		header( 'X-Frame-Options: SAMEORIGIN' );
		header( 'X-XSS-Protection: 1; mode=block' );
		header( 'Referrer-Policy: strict-origin-when-cross-origin' );
	}
);

// Sanitize SVG uploads
add_filter(
	'wp_handle_upload_prefilter',
	function ( $file ) {
		if ( 'image/svg+xml' === $file['type'] ) {
			if ( ! sanitize_svg( $file['tmp_name'] ) ) {
				$file['error'] = 'Invalid SVG file';
			}
		}
		return $file;
	}
);
