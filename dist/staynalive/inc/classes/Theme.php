<?php
namespace StayNAlive;

class Theme {
    private static $instance = null;
    
    public static function get_instance() {
        if (null === self::$instance) {
            self::$instance = new self();
        }
        return self::$instance;
    }
    
    private function __construct() {
        $this->setup_hooks();
    }
    
    private function setup_hooks() {
        add_action('after_setup_theme', [$this, 'setup']);
        add_action('wp_enqueue_scripts', [$this, 'enqueue_scripts']);
        add_action('init', [$this, 'register_block_styles']);
    }
    
    public function setup() {
        // Theme setup code
    }
    
    public function enqueue_scripts() {
        // Enqueue scripts code
    }
    
    public function register_block_styles() {
        // Block styles registration code
    }
} 