<?php
/**
 * Enhanced Theme Check Validation
 *
 * @package StayNAlive
 */

namespace StayNAlive\ThemeCheck;

// Exit if accessed directly
if (!defined('ABSPATH')) {
    exit;
}

class ThemeCompatibilityChecker {
    private $issues = [];
    private $warnings = [];
    private $info = [];
    
    // List of functions that should be in plugins, not themes
    private $plugin_territory = [
        'add_shortcode' => 'Shortcodes should be implemented in plugins, not themes',
        'remove_action wp_head wp_shortlink_wp_head' => 'Removing wp_shortlink_wp_head is plugin territory',
        'remove_action wp_head wp_generator' => 'Removing wp_generator is plugin territory',
        'remove_action wp_head rsd_link' => 'Removing rsd_link is plugin territory'
    ];

    /**
     * Run all compatibility checks
     */
    public function check_compatibility() {
        $this->check_plugin_territory();
        $this->check_screenshot();
        $this->check_text_domain();
        $this->check_block_styles();
        $this->check_theme_headers();
        
        return [
            'issues' => $this->issues,
            'warnings' => $this->warnings,
            'info' => $this->info
        ];
    }

    /**
     * Check for plugin-territory functionality
     */
    private function check_plugin_territory() {
        $files_to_check = [
            'inc/social-feeds.php',
            'inc/performance.php',
            'inc/security.php'
        ];

        foreach ($files_to_check as $file) {
            $full_path = get_template_directory() . '/' . $file;
            if (!file_exists($full_path)) {
                continue;
            }

            $content = file_get_contents($full_path);
            $lines = explode("\n", $content);

            foreach ($lines as $line_num => $line) {
                foreach ($this->plugin_territory as $function => $message) {
                    if (strpos($line, $function) !== false) {
                        $this->issues[] = sprintf(
                            'REQUIRED: The theme uses %s in the file %s. %s Line %d: %s',
                            $function,
                            $file,
                            $message,
                            $line_num + 1,
                            trim($line)
                        );
                    }
                }
            }
        }
    }

    /**
     * Check screenshot dimensions
     */
    private function check_screenshot() {
        $screenshot = get_template_directory() . '/screenshot.png';
        
        if (!file_exists($screenshot)) {
            $this->issues[] = 'REQUIRED: Screenshot.png is missing.';
            return;
        }

        $size = getimagesize($screenshot);
        if ($size) {
            $width = $size[0];
            $height = $size[1];
            $ratio = $width / $height;
            
            if (abs($ratio - 4/3) > 0.01) {
                $this->issues[] = 'REQUIRED: Screenshot dimensions are wrong! Ratio of width to height should be 4:3.';
            }
            
            if ($width < 1200 || $height < 900) {
                $this->warnings[] = sprintf(
                    'RECOMMENDED: Screenshot size should be 1200x900, to account for HiDPI displays. Current size: %dx%d',
                    $width,
                    $height
                );
            }
        }
    }

    /**
     * Check text domain consistency
     */
    private function check_text_domain() {
        $theme_slug = get_option('stylesheet');
        $text_domain = 'staynalive';
        
        if ($text_domain !== $theme_slug) {
            $this->info[] = sprintf(
                'INFO: Text domain (%s) should match theme slug (%s) for WordPress.org language pack compatibility.',
                $text_domain,
                $theme_slug
            );
        }
    }

    /**
     * Check for block styles implementation
     */
    private function check_block_styles() {
        $has_block_styles = false;
        $theme_files = list_files(get_template_directory(), 2);
        
        foreach ($theme_files as $file) {
            if (strpos($file, '.php') !== false) {
                $content = file_get_contents($file);
                if (strpos($content, 'register_block_style') !== false) {
                    $has_block_styles = true;
                    break;
                }
            }
        }
        
        if (!$has_block_styles) {
            $this->warnings[] = 'RECOMMENDED: No reference to register_block_style was found in the theme. Theme authors are encouraged to implement block styles.';
        }
    }

    /**
     * Check theme headers
     */
    private function check_theme_headers() {
        $style_css = get_template_directory() . '/style.css';
        if (!file_exists($style_css)) {
            $this->issues[] = 'REQUIRED: style.css is missing.';
            return;
        }

        $theme_data = get_file_data($style_css, [
            'Name' => 'Theme Name',
            'ThemeURI' => 'Theme URI',
            'Description' => 'Description',
            'Author' => 'Author',
            'AuthorURI' => 'Author URI',
            'Version' => 'Version',
            'License' => 'License',
            'LicenseURI' => 'License URI',
            'TextDomain' => 'Text Domain',
            'Tags' => 'Tags'
        ]);

        foreach ($theme_data as $key => $value) {
            if (empty($value)) {
                $this->issues[] = sprintf('REQUIRED: %s is missing in style.css header.', $key);
            }
        }
    }
}

/**
 * Display validation results
 */
function display_validation_results() {
    $checker = new ThemeCompatibilityChecker();
    $results = $checker->check_compatibility();
    
    if (!empty($results['issues']) || !empty($results['warnings']) || !empty($results['info'])) {
        echo '<div class="notice notice-warning is-dismissible">';
        echo '<p><strong>Theme Check Results:</strong></p>';
        
        if (!empty($results['issues'])) {
            echo '<h3>Required Fixes:</h3>';
            echo '<ul class="theme-check-error">';
            foreach ($results['issues'] as $issue) {
                echo "<li>$issue</li>";
            }
            echo '</ul>';
        }
        
        if (!empty($results['warnings'])) {
            echo '<h3>Recommendations:</h3>';
            echo '<ul class="theme-check-warning">';
            foreach ($results['warnings'] as $warning) {
                echo "<li>$warning</li>";
            }
            echo '</ul>';
        }
        
        if (!empty($results['info'])) {
            echo '<h3>Information:</h3>';
            echo '<ul class="theme-check-info">';
            foreach ($results['info'] as $info) {
                echo "<li>$info</li>";
            }
            echo '</ul>';
        }
        
        echo '</div>';
    }
}

// Add admin notice for theme check results
add_action('admin_notices', __NAMESPACE__ . '\display_validation_results'); 