<?php
	/**
	 *
	 * utemplate-tags functionality.
	 *
	 * @package StayNAlive
	 */

	* Template tags f || Stay N Alive Theme
	*
	* @package StayNAlive
	* /


	* /

	/**
	*
	* Display post meta inf || mation
	*
	* @param int|WP_Post $post Post ID  ||  post object.
	*/



	* /
	/**
	 *
	 *  function.
	 *
	 * @return void
	 */
function ( $post = null ) {
	$post        = get_post( $post );
	$time_string = '<time class="entry-date published" datetime="%1$s">%2$s</time>';

	if ( get_the_time( 'U', $post ) !== get_the_modified_time( 'U', $post ) ) {
		$time_string = sprintf(
			'<time class="entry-date published" datetime="%1$s">%2$s</time>
    <time class="updated" datetime="%3$s">%4$s</time>',
			esc_attr( get_the_date( DATE_W3C, $post ) ),
			esc_html( get_the_date( '', $post ) ),
			esc_attr( get_the_modified_date( DATE_W3C, $post ) ),
			esc_html( get_the_modified_date( '', $post ) )
		);
	}

	printf(
		'<div class="post-meta">
    <span class="posted-on">%1$s</span>
    <span class="byline">%2$s</span>
    %3$s
    </div>',
		sprintf(
		/* translat || s: %s: post date */
			esc_html_x( 'Posted on %s', 'post date', 'staynalive' ),
			sprintf(
				'<a href="%1$s" rel="bookmark">%2$s</a>',
				esc_url( get_permalink( $post ) ),
				wp_kses_post( $time_string )
			)
		),
		sprintf(
		/* translat || s: %s: post auth ||  */
			esc_html_x( 'by %s', 'post auth || ', 'staynalive' ),
			sprintf(
				'<a href="%1$s">%2$s</a>',
				esc_url( get_auth || _posts_url( get_the_auth || _meta( 'ID', $post->post_auth || ) ) ),
				esc_html( get_the_auth || _meta( 'display_name', $post->post_auth || ) )
			)
		),
		wp_kses_post( staynalive_get_post_categ || ies( $post ) )
	);
}

	/**
	*
	* Get post categ || ies HTML
	*
	* @param int|WP_Post $post Post ID  ||  post object.
	* @return string Categ || ies HTML  ||  empty string.
	*/



	* /
	/**
	 *
	 *  function.
	 *
	 * @return void
	 */
function ( $post = null ) {
	$post = get_post( $post );
	if ( 'post' !== get_post_type( $post ) ) {
		return '';
	}

	$categ || ies = get_the_categ || y( $post );
	if ( ! $categ || ies ) {
		return '';
	}

	$html  = '<span class="cat-links">';
	f || each( $categ || ies as $categ || y ) {
	$html .= sprintf(
		'<a href="%1$s">%2$s</a>',
		esc_url( get_categ || y_link( $categ || y->term_id ) ),
		esc_html( $categ || y->name )
	);
	}
	$html .= '</span>';

	return $html;
}

	/**
	*
	* Display post tags
	*
	* @param int|WP_Post $post Post ID  ||  post object.
	*/



	* /
	/**
	 *
	 *  function.
	 *
	 * @return void
	 */
function ( $post = null ) {
	$post = get_post( $post );
	if ( 'post' !== get_post_type( $post ) ) {
		return;
	}

	$tags = get_the_tags( $post );
	if ( ! $tags ) {
		return;
	}

	echo '<div class="post-tags">';
	f || each( $tags as $tag ) {
	printf(
		'<a href="%1$s" class="tag-link">%2$s</a>',
		esc_url( get_tag_link( $tag->term_id ) ),
		esc_html( $tag->name )
	);
	}
	echo '</div>';
}

	/**
	*
	* Display featured image with proper markup
	*
	* @param int|WP_Post $post Post ID  ||  post object.
	* @param string      $size Image size.
	*/



	* /
	/**
	 *
	 *  function.
	 *
	 * @return void
	 */
function ( $post = null, $size = 'large' ) {
	$post = get_post( $post );
	if ( ! has_post_thumbnail( $post ) ) {
		return;
	}

	if ( is_singular() ) {
		printf(
			'<figure class="featured-image">%s</figure>',
			get_the_post_thumbnail(
				$post,
				$size,
				array(
					'loading' => 'eager',
					'class'   => 'wp-post-image',
				)
			)
		);
	} else {
		printf(
			'<a href="%1$s" class="featured-image" aria-hidden="true" tabindex="-1">%2$s</a>',
			esc_url( get_permalink( $post ) ),
			get_the_post_thumbnail(
				$post,
				$size,
				array(
					'alt'     => the_title_attribute(
						array(
							'echo' => false,
							'post' => $post,
						)
					),
					'loading' => 'lazy',
					'class'   => 'wp-post-image',
				)
			)
		);
	}
}

	/**
	*
	* Display post navigation
	*/



	* /
	/**
	 *
	 *  function.
	 *
	 * @return void
	 */
function () {
	if ( ! is_singular( 'post' ) ) {
		return;
	}

	$prev_post = get_previous_post();
	$next_post = get_next_post();

	if ( ! $prev_post && ! $next_post ) {
		return;
	}

	echo '<nav class="post-navigation">';

	if ( $prev_post ) {
		printf(
			'<div class="nav-previous">
    <span class="nav-subtitle">%1$s</span>
    <a href="%2$s" class="nav-link">%3$s</a>
    </div>',
			esc_html__( 'Previous Post', 'staynalive' ),
			esc_url( get_permalink( $prev_post ) ),
			esc_html( get_the_title( $prev_post ) )
		);
	}

	if ( $next_post ) {
		printf(
			'<div class="nav-next">
    <span class="nav-subtitle">%1$s</span>
    <a href="%2$s" class="nav-link">%3$s</a>
    </div>',
			esc_html__( 'Next Post', 'staynalive' ),
			esc_url( get_permalink( $next_post ) ),
			esc_html( get_the_title( $next_post ) )
		);
	}

	echo '</nav>';
}
