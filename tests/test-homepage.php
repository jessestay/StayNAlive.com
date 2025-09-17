<?php
// Test homepage content loading
function test_homepage_setup() {
    $front_page_id = get_option('page_on_front');
    $show_on_front = get_option('show_on_front');
    
    if ($show_on_front !== 'page') {
        wp_die('Homepage is not set to a static page. Please set in Settings > Reading.');
    }
    
    if (!$front_page_id) {
        wp_die('No homepage is set. Please set in Settings > Reading.');
    }
    
    $front_page = get_post($front_page_id);
    if (!$front_page) {
        wp_die('Homepage content not found.');
    }
    
    return true;
} 