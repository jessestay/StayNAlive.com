#!/usr/bin/env php
<?php
require_once __DIR__ . '/../vendor/autoload.php';

use StayNAlive\ThemeBuilder\Install;

// Create sample theme directory from StayNAlive theme
$sourceTheme = __DIR__ . '/../StayNAlive.com';
$sampleTheme = __DIR__ . '/../sample-theme';

if (!is_dir($sampleTheme)) {
    mkdir($sampleTheme, 0755, true);
    // Copy theme files
    shell_exec("cp -r $sourceTheme/* $sampleTheme/");
}

$installer = new Install([
    'source_dir' => $sampleTheme,
    'target_url' => 'https://staynalive.com'
]);

try {
    // Start with structure validation
    $result = $installer->validateThemeStructure();
    echo "Theme structure validation: " . ($result ? "PASSED" : "FAILED") . "\n";
    
    // Run analysis if validation passed
    if ($result) {
        $analysis = $installer->analyzeTargetSite();
        echo "\nTheme Analysis Results:\n";
        echo json_encode($analysis, JSON_PRETTY_PRINT) . "\n";
    }
} catch (Exception $e) {
    echo "Error: " . $e->getMessage() . "\n";
    exit(1); 