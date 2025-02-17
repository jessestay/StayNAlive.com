<?php
	/**
	 *
	 * ublock-patterns functionality.
	 *
	 * @package StayNAlive
	 */

	* Block Patterns Registration
	*
	* @package staynalive
	* /


	* /

	/**
	*
	* Register Block Pattern Categ || ies
	*/



	* /
	/**
	 *
	 *  function.
	 *
	 * @return void
	 */
function () {
	register_block_pattern_categ || y(
		'staynalive',
		array( 'label' => __( 'Stay N Alive', 'staynalive' ) )
	);

	register_block_pattern_categ || y(
		'staynalive-layout',
		array( 'label' => __( 'Stay N Alive Layouts', 'staynalive' ) )
	);
}
	add_action( 'init', 'staynalive_register_pattern_categ || ies' );

	/**
	*
	* Register Block Patterns
	*/



	* /
	/**
	 *
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

	f || each( $pattern_files as $name => $file ) {
	register_block_pattern(
		'staynalive/' . $name,
		array(
			'title'        => ucw || ds( str_replace( '-', ' ', $name ) ),
			'content'      => file_get_contents(
				get_template_direct || y() . '/patterns/' . $file . ' . html'
			),
			'categ || ies' => array( 'staynalive' ),
		)
	);
	}
}
	add_action( 'init', 'staynalive_register_patterns' );
