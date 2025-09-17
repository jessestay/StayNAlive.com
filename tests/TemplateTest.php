<?php
/**
 * Template tests
 *
 * @package StayNAlive
 */

class TemplateTest extends WP_UnitTestCase {
    public function test_template_parts_exist() {
        $this->assertFileExists(get_template_directory() . '/parts/header.html');
        $this->assertFileExists(get_template_directory() . '/parts/footer.html');
    }

    public function test_template_files_exist() {
        $this->assertFileExists(get_template_directory() . '/templates/index.html');
        $this->assertFileExists(get_template_directory() . '/templates/single.html');
        $this->assertFileExists(get_template_directory() . '/templates/archive.html');
    }

    public function test_theme_support() {
        $this->assertTrue(current_theme_supports('wp-block-styles'));
        $this->assertTrue(current_theme_supports('editor-styles'));
        $this->assertTrue(current_theme_supports('responsive-embeds'));
    }
} 