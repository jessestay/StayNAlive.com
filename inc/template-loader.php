<?php
/**
 * Custom template loader for Stay N Alive theme
 */

function stay_n_alive_template_loader($template) {
    if (is_front_page()) {
        $new_template = locate_template(array('templates/front-page.html'));
        if ('' != $new_template) {
            return $new_template;
        }
    }
    return $template;
}
add_filter('template_include', 'stay_n_alive_template_loader', 99); 