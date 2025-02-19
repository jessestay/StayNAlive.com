<?php
/**
 * Performance Class
 *
 * @package StayNAlive
 */

if (!defined('ABSPATH')) {
    exit;
}

class Stay_N_Alive_Performance {
    public function __construct() {
        add_action('init', array($this, 'disable_emojis'));
        add_action('wp_enqueue_scripts', array($this, 'optimize_scripts'), 99);
    }

    public function disable_emojis() {
        remove_action('wp_head', 'print_emoji_detection_script', 7);
        remove_action('wp_print_styles', 'print_emoji_styles');
    }

    public function optimize_scripts() {
        if (!is_admin()) {
            wp_dequeue_style('wp-block-library');
            wp_dequeue_style('wp-block-library-theme');
        }
    }
}

new Stay_N_Alive_Performance(); 