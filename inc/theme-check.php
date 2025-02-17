<?php
/**
 * Theme Compatibility Checker
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
    private $required_files = [
        'templates/index.html' => 'Main Index Template',
        'theme.json' => 'Theme Configuration',
        'parts/header.html' => 'Header Template Part',
        'parts/footer.html' => 'Footer Template Part',
        'style.css' => 'Theme Stylesheet'
    ];

    private $required_theme_support = [
        'wp-block-styles' => 'Block Styles',
        'editor-styles' => 'Editor Styles',
        'block-templates' => 'Block Templates',
        'block-template-parts' => 'Block Template Parts'
    ];

    /**
     * Run all compatibility checks
     */
    public function check_compatibility() {
        $this->check_wp_version();
        $this->check_php_version();
        $this->check_required_files();
        $this->check_theme_support();
        $this->check_theme_json();
        $this->check_template_structure();
        
        return [
            'issues' => $this->issues,
            'warnings' => $this->warnings
        ];
    }

    /**
     * Check WordPress version compatibility
     */
    private function check_wp_version() {
        global $wp_version;
        if (version_compare($wp_version, '6.7', '<')) {
            $this->issues[] = sprintf(
                __('WordPress version 6.7 or higher is required. Current version is %s.', 'staynalive'),
                $wp_version
            );
        }
    }

    /**
     * Check PHP version compatibility
     */
    private function check_php_version() {
        if (version_compare(PHP_VERSION, '7.4', '<')) {
            $this->issues[] = sprintf(
                __('PHP version 7.4 or higher is required. Current version is %s.', 'staynalive'),
                PHP_VERSION
            );
        }
    }

    /**
     * Check required files exist
     */
    private function check_required_files() {
        foreach ($this->required_files as $file => $name) {
            if (!file_exists(get_template_directory() . '/' . $file)) {
                $this->issues[] = sprintf(
                    __('Required file missing: %s (%s)', 'staynalive'),
                    $name,
                    $file
                );
            }
        }
    }

    /**
     * Check required theme support
     */
    private function check_theme_support() {
        foreach ($this->required_theme_support as $feature => $name) {
            if (!current_theme_supports($feature)) {
                $this->issues[] = sprintf(
                    __('Missing required theme support: %s', 'staynalive'),
                    $name
                );
            }
        }
    }

    /**
     * Check theme.json structure
     */
    private function check_theme_json() {
        $theme_json_path = get_template_directory() . '/theme.json';
        if (file_exists($theme_json_path)) {
            $theme_json = json_decode(file_get_contents($theme_json_path), true);
            
            if (json_last_error() !== JSON_ERROR_NONE) {
                $this->issues[] = __('Invalid theme.json structure', 'staynalive');
                return;
            }

            $required_keys = ['version', 'settings', 'templateParts'];
            foreach ($required_keys as $key) {
                if (!isset($theme_json[$key])) {
                    $this->issues[] = sprintf(
                        __('Missing required key in theme.json: %s', 'staynalive'),
                        $key
                    );
                }
            }
        }
    }

    /**
     * Check template structure
     */
    private function check_template_structure() {
        $templates_dir = get_template_directory() . '/templates';
        if (is_dir($templates_dir)) {
            foreach (glob($templates_dir . '/*.html') as $template) {
                $this->validate_template_file($template);
            }
        }
    }

    /**
     * Validate individual template file
     */
    private function validate_template_file($template_path) {
        $content = file_get_contents($template_path);
        $template_name = basename($template_path);

        // Check for required block structure
        if (!preg_match('/<!-- wp:template-part {"slug":"header"/', $content)) {
            $this->warnings[] = sprintf(
                __('Template %s may be missing header template part', 'staynalive'),
                $template_name
            );
        }

        if (!preg_match('/<!-- wp:template-part {"slug":"footer"/', $content)) {
            $this->warnings[] = sprintf(
                __('Template %s may be missing footer template part', 'staynalive'),
                $template_name
            );
        }

        // Check for unclosed block comments
        preg_match_all('/<!-- wp:([^\s]+)/', $content, $openings);
        preg_match_all('/<!-- \/wp:([^\s]+)/', $content, $closings);
        
        if (count($openings[1]) !== count($closings[1])) {
            $this->issues[] = sprintf(
                __('Template %s has mismatched block comments', 'staynalive'),
                $template_name
            );
        }
    }
}

/**
 * Add admin page for theme compatibility checker
 */
function add_theme_check_page() {
    add_theme_page(
        __('Theme Compatibility', 'staynalive'),
        __('Theme Compatibility', 'staynalive'),
        'manage_options',
        'theme-compatibility',
        __NAMESPACE__ . '\render_theme_check_page'
    );
}
add_action('admin_menu', __NAMESPACE__ . '\add_theme_check_page');

/**
 * Render theme compatibility check page
 */
function render_theme_check_page() {
    $checker = new ThemeCompatibilityChecker();
    $results = $checker->check_compatibility();
    ?>
    <div class="wrap">
        <h1><?php _e('Theme Compatibility Check', 'staynalive'); ?></h1>
        
        <?php if (empty($results['issues']) && empty($results['warnings'])): ?>
            <div class="notice notice-success">
                <p><?php _e('No compatibility issues found!', 'staynalive'); ?></p>
            </div>
        <?php else: ?>
            <?php if (!empty($results['issues'])): ?>
                <div class="notice notice-error">
                    <h3><?php _e('Issues Found:', 'staynalive'); ?></h3>
                    <ul>
                        <?php foreach ($results['issues'] as $issue): ?>
                            <li><?php echo esc_html($issue); ?></li>
                        <?php endforeach; ?>
                    </ul>
                </div>
            <?php endif; ?>
            
            <?php if (!empty($results['warnings'])): ?>
                <div class="notice notice-warning">
                    <h3><?php _e('Warnings:', 'staynalive'); ?></h3>
                    <ul>
                        <?php foreach ($results['warnings'] as $warning): ?>
                            <li><?php echo esc_html($warning); ?></li>
                        <?php endforeach; ?>
                    </ul>
                </div>
            <?php endif; ?>
        <?php endif; ?>
    </div>
    <?php
} 