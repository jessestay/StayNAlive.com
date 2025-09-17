<?php
/**
 * Block Template Validator
 * 
 * @package StayNAlive
 */

namespace StayNAlive\BlockValidator;

function validate_block_templates() {
    $template_dir = get_template_directory() . '/templates/';
    $pattern_dir = get_template_directory() . '/patterns/';
    $errors = [];

    // Validate templates
    foreach (glob($template_dir . '*.html') as $template) {
        $content = file_get_contents($template);
        $template_name = basename($template);
        
        // Check for basic HTML structure
        if (!validate_html_structure($content)) {
            $errors[] = "Invalid HTML structure in $template_name";
        }
        
        // Validate block syntax
        $block_errors = validate_block_syntax($content);
        if (!empty($block_errors)) {
            $errors = array_merge($errors, array_map(function($error) use ($template_name) {
                return "$template_name: $error";
            }, $block_errors));
        }
        
        // Check for required patterns
        $pattern_errors = check_required_patterns($content);
        if (!empty($pattern_errors)) {
            $errors = array_merge($errors, array_map(function($error) use ($template_name) {
                return "$template_name: Missing pattern - $error";
            }, $pattern_errors));
        }
        
        // Verify template parts exist
        $part_errors = verify_template_parts($content);
        if (!empty($part_errors)) {
            $errors = array_merge($errors, array_map(function($error) use ($template_name) {
                return "$template_name: Missing template part - $error";
            }, $part_errors));
        }
    }

    return $errors;
}

function validate_html_structure($content) {
    libxml_use_internal_errors(true);
    $doc = new \DOMDocument();
    $doc->loadHTML($content, LIBXML_HTML_NOIMPLIED | LIBXML_HTML_NODEFDTD);
    $errors = libxml_get_errors();
    libxml_clear_errors();
    return empty($errors);
}

function validate_block_syntax($content) {
    $errors = [];
    
    // Check for matching block comments
    preg_match_all('/<!-- wp:([^\s]+)/', $content, $openings);
    preg_match_all('/<!-- \/wp:([^\s]+)/', $content, $closings);
    
    foreach ($openings[1] as $block) {
        if (!in_array($block, $closings[1])) {
            $errors[] = "Unclosed block: $block";
        }
    }
    
    return $errors;
}

function check_required_patterns($content) {
    $missing = [];
    preg_match_all('/wp:pattern {"slug":"([^"]+)"}/', $content, $matches);
    
    foreach ($matches[1] as $pattern) {
        $pattern_file = get_template_directory() . '/patterns/' . basename($pattern) . '.html';
        if (!file_exists($pattern_file)) {
            $missing[] = $pattern;
        }
    }
    
    return $missing;
}

function verify_template_parts($content) {
    $missing = [];
    preg_match_all('/wp:template-part {"slug":"([^"]+)"/', $content, $matches);
    
    foreach ($matches[1] as $part) {
        $part_file = get_template_directory() . '/parts/' . $part . '.html';
        if (!file_exists($part_file)) {
            $missing[] = $part;
        }
    }
    
    return $missing;
}

// Add to admin menu
add_action('admin_menu', function() {
    add_management_page(
        'Block Template Validator',
        'Template Validator',
        'manage_options',
        'block-template-validator',
        __NAMESPACE__ . '\validator_page'
    );
});

function validator_page() {
    echo '<div class="wrap">';
    echo '<h1>Block Template Validator</h1>';
    
    $errors = validate_block_templates();
    
    if (empty($errors)) {
        echo '<div class="notice notice-success"><p>All templates validated successfully!</p></div>';
    } else {
        echo '<div class="notice notice-error"><p>Template validation errors found:</p>';
        echo '<ul>';
        foreach ($errors as $error) {
            echo "<li>$error</li>";
        }
        echo '</ul></div>';
    }
    
    echo '</div>';
} 