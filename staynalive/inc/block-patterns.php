<?php
/**
 * Block Patterns Registration
 *
 * @package Stay_N_Alive
 */

namespace StayNAlive\Patterns;

if (!defined('ABSPATH')) {
    exit; // Exit if accessed directly
}

/**
 * Register custom block pattern category
 */
function register_pattern_category() {
    register_block_pattern_category('staynalive', array(
        'label' => __('Stay N Alive', 'stay-n-alive')
    ));
}
add_action('init', __NAMESPACE__ . '\register_pattern_category');

/**
 * Register block patterns
 */
function register_block_patterns() {
    $patterns = array(
        'bio-link-button',
        'social-grid',
        'author-bio'
    );
    
    foreach ($patterns as $pattern) {
        $pattern_file = get_template_directory() . "/patterns/{$pattern}.html";
        if (file_exists($pattern_file)) {
            register_block_pattern(
                'staynalive/' . $pattern,
                array(
                    'title'       => ucwords(str_replace('-', ' ', $pattern)),
                    'content'     => file_get_contents($pattern_file),
                    'categories'  => array('staynalive'),
                )
            );
        }
    }
}
add_action('init', __NAMESPACE__ . '\register_block_patterns');

/**
 * Register Block Patterns
 */
function stay_n_alive_register_block_patterns() {
    register_block_pattern(
        'stay-n-alive/social-grid',
        array(
            'title'       => __('Social Media Grid', 'stay-n-alive'),
            'description' => __('A grid of social media feeds', 'stay-n-alive'),
            'content'     => file_get_contents(get_theme_file_path('patterns/social-grid.html')),
            'categories'  => array('featured')
        )
    );

    register_block_pattern(
        'stay-n-alive/bio-link',
        array(
            'title'       => __('Bio Link Button', 'stay-n-alive'),
            'description' => __('A styled bio link button', 'stay-n-alive'),
            'content'     => file_get_contents(get_theme_file_path('patterns/bio-link-button.html')),
            'categories'  => array('buttons')
        )
    );
}
add_action('init', 'stay_n_alive_register_block_patterns'); 