<?php
/**
 * Block Patterns Registration
 *
 * @package Stay_N_Alive
 */

namespace StayNAlive\Patterns;

if (!defined('ABSPATH')) {
    exit;
}

/**
 * Register custom block patterns for the theme
 */
function register_block_patterns() {
    // ... existing pattern registrations ...
    
    register_block_pattern(
        'staynalive/hero-section',
        array(
            'title'       => __('Hero Section', 'stay-n-alive'),
            'description' => __('A hero section with heading and description', 'stay-n-alive'),
            'content'     => file_get_contents(get_template_directory() . '/patterns/hero-section.html'),
            'categories'  => array('header')
        )
    );

    register_block_pattern(
        'staynalive/expertise-section',
        array(
            'title'       => __('Expertise Section', 'stay-n-alive'),
            'description' => __('A section showcasing areas of expertise', 'stay-n-alive'),
            'content'     => file_get_contents(get_template_directory() . '/patterns/expertise-section.html'),
            'categories'  => array('featured')
        )
    );

    register_block_pattern(
        'staynalive/featured-posts',
        array(
            'title'       => __('Featured Posts Grid', 'stay-n-alive'),
            'description' => __('A grid of featured blog posts', 'stay-n-alive'),
            'content'     => file_get_contents(get_template_directory() . '/patterns/featured-posts.html'),
            'categories'  => array('query')
        )
    );

    register_block_pattern(
        'staynalive/cta-section',
        array(
            'title'       => __('Call to Action Section', 'stay-n-alive'),
            'description' => __('A call to action section with heading and button', 'stay-n-alive'),
            'content'     => file_get_contents(get_template_directory() . '/patterns/cta-section.html'),
            'categories'  => array('featured')
        )
    );
}

/**
 * Register pattern categories
 */
function register_pattern_categories() {
    register_block_pattern_category(
        'staynalive',
        array('label' => __('Stay N Alive', 'stay-n-alive'))
    );
}

add_action('init', __NAMESPACE__ . '\\register_pattern_categories');
add_action('init', __NAMESPACE__ . '\\register_block_patterns'); 