<?php
/**
 * Block tests
 *
 * @package StayNAlive
 */

class BlockTest extends WP_UnitTestCase {
    public function test_block_patterns_registered() {
        $patterns = WP_Block_Patterns_Registry::get_instance()->get_all_registered();
        $this->assertNotEmpty($patterns);
    }

    public function test_block_styles_registered() {
        $styles = WP_Block_Styles_Registry::get_instance()->get_all_registered();
        $this->assertNotEmpty($styles);
    }

    public function test_theme_json_valid() {
        $theme_json_file = get_template_directory() . '/theme.json';
        $this->assertFileExists($theme_json_file);
        
        $theme_json = json_decode(file_get_contents($theme_json_file), true);
        $this->assertNotNull($theme_json);
        $this->assertArrayHasKey('version', $theme_json);
        $this->assertArrayHasKey('settings', $theme_json);
    }
} 