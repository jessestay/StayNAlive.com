<?php
/**
 * Theme tests
 *
 * @package StayNAlive
 */

class ThemeTest extends WP_UnitTestCase {
    public function test_theme_setup() {
        $this->assertTrue(current_theme_supports('editor-styles'));
        $this->assertTrue(current_theme_supports('wp-block-styles'));
    }
} 