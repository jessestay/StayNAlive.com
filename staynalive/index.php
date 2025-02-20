<?php
/**
 * The main template file
 *
 * @package StayNAlive
 */

if ( ! defined( 'ABSPATH' ) ) {
    exit; // Exit if accessed directly
}

get_header();
?>

<main id="primary" class="site-main">
    <?php
    if ( have_posts() ) :
        while ( have_posts() ) :
            the_post();
            get_template_part( 'parts/content', get_post_type() );
        endwhile;
        
        the_posts_navigation();
    else :
        get_template_part( 'parts/content', 'none' );
    endif;
    ?>
</main>

<?php
get_footer(); 