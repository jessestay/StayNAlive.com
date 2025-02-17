<?php
/**
 * block-patterns functionality.
 *
 * @package StayNAlive
 */

* Block Patterns Registration
*
* @package staynalive
* /


* /

/**
 * Register Block Pattern Categories
 */



* /
/**
 *  function.
 *
 * @return void
 */
function () {
	register_block_pattern_category(
		'staynalive',
		array( 'label' => __( 'Stay N Alive', 'staynalive' ) )
	);

	register_block_pattern_category(
		'staynalive-layout',
		array( 'label' => __( 'Stay N Alive Layouts', 'staynalive' ) )
	);
}
add_action( 'init', 'staynalive_register_pattern_categories' );

/**
 * Register Block Patterns
 */



* /
/**
 *  function.
 *
 * @return void
 */
function () {
	$pattern_files = array(
		'header'     => 'custom-header',
		'footer'     => 'footer',
		'page'       => 'content-page',
		'search'     => 'content-search',
		'no-results' => 'no-results',
		'comments'   => 'comments',
		'sidebar'    => 'sidebar',
	);

	foreach ( $pattern_files as $name => $file ) {
		register_block_pattern(
			'staynalive/' . $name,
			array(
				'title'      => ucwords( str_replace( '-', ' ', $name ) ),
				'content'    => file_get_contents(
					get_template_directory() . '/patterns/' . $file . '.html'
				),
				'categories' => array( 'staynalive' ),
			)
		);
	}
}
add_action( 'init', 'staynalive_register_patterns' );
