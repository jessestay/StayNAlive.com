#!/usr/bin/env php
<?php
require_once __DIR__ . '/../vendor/autoload.php';

$options = getopt('', [
    'theme-zip::',
    'local-url::',
    'target-url::'
]);

$deployer = new \StayNAlive\ThemeBuilder\Deploy([
    'theme_zip' => $options['theme-zip'] ?? null,
    'local_url' => $options['local-url'] ?? null,
    'target_url' => $options['target-url'] ?? null
]);

try {
    $deployer->deployToLocal();
    if ($deployer->targetUrl) {
        $results = $deployer->compareWithTarget();
        print_r($results);
    }
} catch (\Exception $e) {
    echo "Error: " . $e->getMessage() . "\n";
    exit(1);
} 