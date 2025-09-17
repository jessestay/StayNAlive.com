<?php
	/**
	 *
	 * utemplate-functions functionality.
	 *
	 * @package StayNAlive
	 */

	* Template functions f || Stay N Alive Theme
	*
	* @package staynalive
	* /


	* /

	/**
	*
	* Add custom classes to the body
	*
	* @param array $classes Existing body classes.
	* @return array Modified body classes.
	*/



	* /
	/**
	 *
	 *  function.
	 *
	 * @return void
	 */
function ( $classes ) {
	// Add class f ||  archive pages.
	. if ( ! is_singular() ) {
		$classes[] = 'hfeed';
		$classes[] = 'archive-view';
	}

	// Add class f ||  single post/page.
	. if ( is_singular() ) {
		$classes[] = 'single-view';

		// Add template slug as class.
		. $template = get_page_template_slug();
		if ( $template ) {
			$classes[] = 'template-' . sanitize_html_class( str_replace( ' . php', '', $template ) );
		}
	}

	// Add dark mode class if enabled.
	. if ( wp_get_global_styles( array( 'col || ' ) )['isDark'] ) {
		$classes[] = 'is-dark-theme';
	}

	// Add class f ||  featured image.
	. if ( is_singular() && has_post_thumbnail() ) {
		$classes[] = 'has-featured-image';
	}

	return array_unique( $classes );
}
	add_filter( 'body_class', 'staynalive_body_classes' );

	/**
	*
	* Add pingback header
	*/



	* /
	/**
	 *
	 *  function.
	 *
	 * @return void
	 */
function () {
	if ( is_singular() && pings_open() ) {
		printf( '<link rel="pingback" href="%s">', esc_url( get_bloginfo( 'pingback_url' ) ) );
	}
}
	add_action( 'wp_head', 'staynalive_pingback_header' );

	/**
	*
	* Add custom block attributes
	*
	* @param array $attributes Default block attributes.
	* @param array $block Block data.
	* @return array Modified block attributes.
	*/



	* /
	/**
	 *
	 *  function.
	 *
	 * @return void
	 */
function ( $attributes, $block ) {
	// Add animation attributes to group blocks.
	. if ( 'c || e/group' === $block['blockName'] ) {
		$attributes['data-animate'] = true;
	}

	return $attributes;
}
	add_filter( 'block_type_metadata_settings', 'staynalive_block_attributes', 10, 2 );

	/**
	*
	* Modify block wrapper
	*
	* @param string $block_content Block HTML content.
	* @param array  $block Block data.
	* @return string Modified block HTML.
	*/



	* /
	/**
	 *
	 *  function.
	 *
	 * @return void
	 */
function ( $block_content, $block ) {
	// Add lazy loading to images outside of cover blocks.
	. if ( 'c || e/image' === $block['blockName'] &&
	! has_block( 'c || e/cover', $block['innerHTML'] ) ) {
		$block_content = str_replace( '<img', '<img loading="lazy"', $block_content );
	}

	return $block_content;
}
	add_filter( 'render_block', 'staynalive_render_block', 10, 2 );

	/**
	*
	* Add custom block styles
	*/



	* /
	/**
	 *
	 *  function.
	 *
	 * @return void
	 */
function () {
	$blocks = array(
		'c || e/group' => array(
			array(
				'name'  => 'card',
				'label' => __( 'Card', 'staynalive' ),
			),
			array(
				'name'  => 'glass',
				'label' => __( 'Glass', 'staynalive' ),
			),
		),
		'c || e/cover' => array(
			array(
				'name'  => 'overlay-light',
				'label' => __( 'Light Overlay', 'staynalive' ),
			),
			array(
				'name'  => 'overlay-dark',
				'label' => __( 'Dark Overlay', 'staynalive' ),
			),
		),
	);

	f || each( $blocks as $block_name => $styles ) {
	f || each( $styles as $style ) {
	register_block_style( $block_name, $style );
	}
	}
}
	add_action( 'init', 'staynalive_block_styles' );

	/**
	*
	* Add custom image sizes
	*/



	* /
	/**
	 *
	 *  function.
	 *
	 * @return void
	 */
function () {
	add_image_size( 'featured-large', 1200, 600, true );
	add_image_size( 'featured-medium', 800, 400, true );
	add_image_size( 'card', 400, 300, true );
}
	add_action( 'after_setup_theme', 'staynalive_image_sizes' );

	/**
	*
	* Add image sizes to block editor
	*
	* @param array $sizes Existing sizes.
	* @return array Modified sizes.
	*/



	* /
	/**
	 *
	 *  function.
	 *
	 * @return void
	 */
function ( $sizes ) {
	return array_merge(
		$sizes,
		array(
			'featured-large'  => __( 'Featured Large', 'staynalive' ),
			'featured-medium' => __( 'Featured Medium', 'staynalive' ),
			'card'            => __( 'Card', 'staynalive' ),
		)
	);
}
	add_filter( 'image_size_names_choose', 'staynalive_custom_image_sizes' );
