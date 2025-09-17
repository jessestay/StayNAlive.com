<?php
/**
 * PHPUnit bootstrap file
 *
 * @package StayNAlive
 */

$_tests_dir = getenv('WP_TESTS_DIR');

if (!$_tests_dir) {
    $_tests_dir = rtrim(sys_get_temp_dir(), '/\\') . '/wordpress-tests-lib';
}

// Forward custom PHPUnit Polyfills configuration to PHPUnit bootstrap file.
$_phpunit_polyfills_path = getenv('WP_TESTS_PHPUNIT_POLYFILLS_PATH');
if (false !== $_phpunit_polyfills_path) {
    define('WP_TESTS_PHPUNIT_POLYFILLS_PATH', $_phpunit_polyfills_path);
}

require_once $_tests_dir . '/includes/functions.php';

function _register_theme() {
    $theme_dir = dirname(__DIR__);
    $current_theme = basename($theme_dir);
    $theme_root = dirname($theme_dir);

    add_filter('theme_root', function() use ($theme_root) {
        return $theme_root;
    });

    register_theme_directory($theme_root);

    add_filter('pre_option_template', function() use ($current_theme) {
        return $current_theme;
    });
    add_filter('pre_option_stylesheet', function() use ($current_theme) {
        return $current_theme;
    });
}
tests_add_filter('muplugins_loaded', '_register_theme');

require $_tests_dir . '/includes/bootstrap.php'; 