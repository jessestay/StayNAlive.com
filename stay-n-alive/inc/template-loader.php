<?php
/**
 * Custom template loader
 *
 * @package Stay_N_Alive
 */

namespace StayNAlive\Templates;

if (!defined('ABSPATH')) {
    exit; // Exit if accessed directly
}

/**
 * Filter template hierarchy for custom post types
 */
function filter_templates($template) {
    // Get the post type
    $post_type = get_post_type();
    
    // Only modify template for custom post types
    if ($post_type && !in_array($post_type, array('post', 'page'))) {
        $custom_template = locate_template(array(
            "templates/{$post_type}-single.html",
            "templates/single.html"
        ));
        
        if ($custom_template) {
            return $custom_template;
        }
    }
    
    return $template;
}
add_filter('single_template', __NAMESPACE__ . '\filter_templates');

/**
 * Load custom templates
 */
function stay_n_alive_template_loader( $template ) {
    if ( is_page_template( 'templates/link-bio.html' ) ) {
        return get_theme_file_path( 'templates/link-bio.html' );
    }
    return $template;
}
add_filter( 'template_include', 'stay_n_alive_template_loader' ); 