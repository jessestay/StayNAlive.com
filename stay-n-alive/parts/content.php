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
    <header class="entry-header">
        <?php
        if (is_singular()) :
            the_title('<h1 class="entry-title">', '</h1>');
        else :
            the_title('<h2 class="entry-title"><a href="' . esc_url(get_permalink()) . '" rel="bookmark">', '</a></h2>');
        endif;
        ?>

        <?php if ('post' === get_post_type()) : ?>
            <div class="entry-meta">
                <?php
                stay_n_alive_posted_on();
                stay_n_alive_posted_by();
                ?>
            </div>
        <?php endif; ?>
    </header>

    <?php if (has_post_thumbnail()) : ?>
        <div class="post-thumbnail">
            <?php the_post_thumbnail(); ?>
        </div>
    <?php endif; ?>

    <div class="entry-content">
        <?php
        if (is_singular()) :
            the_content();
            wp_link_pages();
        else :
            the_excerpt();
            echo '<p><a class="read-more" href="' . esc_url(get_permalink()) . '">' . esc_html__('Read More', 'stay-n-alive') . '</a></p>';
        endif;
        ?>
    </div>

    <footer class="entry-footer">
        <?php
        $categories = get_the_category_list(', ');
        $tags = get_the_tag_list('', ', ');
        
        if ($categories) {
            echo '<span class="cat-links">' . $categories . '</span>';
        }
        if ($tags) {
            echo '<span class="tags-links">' . $tags . '</span>';
        }
        ?>
    </footer>
</article> 