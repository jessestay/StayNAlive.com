<?php
/**
 * Template part for displaying posts
 *
 * @package Stay_N_Alive
 */

if (!defined('ABSPATH')) {
    exit; // Exit if accessed directly
}
?>

<article id="post-<?php the_ID(); ?>" <?php post_class(); ?>>
    <?php if (has_post_thumbnail()) : ?>
        <div class="post-thumbnail">
            <?php the_post_thumbnail('large'); ?>
        </div>
    <?php endif; ?>

    <header class="entry-header">
        <?php if (is_singular()) : ?>
            <?php the_title('<h1 class="entry-title">', '</h1>'); ?>
        <?php else : ?>
            <?php the_title(sprintf('<h2 class="entry-title"><a href="%s" rel="bookmark">', esc_url(get_permalink())), '</a></h2>'); ?>
        <?php endif; ?>

        <?php if ('post' === get_post_type()) : ?>
            <div class="entry-meta">
                <?php
                stay_n_alive_posted_on();
                stay_n_alive_posted_by();
                ?>
            </div>
        <?php endif; ?>
    </header>

    <div class="entry-content">
        <?php
        if (is_singular()) :
            the_content();
        else :
            the_excerpt();
            echo '<p><a class="read-more" href="' . esc_url(get_permalink()) . '">' . esc_html__('Read More', 'stay-n-alive') . '</a></p>';
        endif;
        ?>
    </div>

    <footer class="entry-footer">
        <?php stay_n_alive_entry_footer(); ?>
    </footer>
</article> 