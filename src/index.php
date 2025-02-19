<?php
/**
 * The main template file
 *
 * @package Stay_N_Alive
 */

if ( ! defined( 'ABSPATH' ) ) {
    exit; // Exit if accessed directly
}

get_header();

if ( have_posts() ) {
    while ( have_posts() ) {
        the_post();
        get_template_part( 'parts/content', get_post_type() );
    }

    the_posts_pagination( array(
        'prev_text' => __( 'Previous page', 'stay-n-alive' ),
        'next_text' => __( 'Next page', 'stay-n-alive' ),
    ) );
} else {
    get_template_part( 'parts/content', 'none' );
}

get_footer(); 