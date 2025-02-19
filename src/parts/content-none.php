<?php
/**
 * Template part for displaying a message when no posts are found
 *
 * @package Stay_N_Alive
 */

if (!defined('ABSPATH')) {
    exit; // Exit if accessed directly
}
?>

<section class="no-results not-found">
    <header class="page-header">
        <h1 class="page-title"><?php esc_html_e('Nothing Found', 'stay-n-alive'); ?></h1>
    </header>

    <div class="page-content">
        <?php if (is_search()) : ?>
            <p><?php esc_html_e('Sorry, but nothing matched your search terms. Please try again with some different keywords.', 'stay-n-alive'); ?></p>
            <?php get_search_form(); ?>
        <?php else : ?>
            <p><?php esc_html_e('It seems we can&rsquo;t find what you&rsquo;re looking for. Perhaps searching can help.', 'stay-n-alive'); ?></p>
            <?php get_search_form(); ?>
        <?php endif; ?>
    </div>
</section> 