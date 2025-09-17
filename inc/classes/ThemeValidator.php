<?php
namespace StayNAlive\ThemeBuilder;

class ThemeValidator {
    private array $requiredDirs = [
        'templates',
        'parts',
        'patterns',
        'assets/css',
        'inc'
    ];

    private array $requiredFiles = [
        'style.css',
        'theme.json',
        'functions.php'
    ];

    public function validateStructure(string $themeDir): array {
        $issues = [];
        
        foreach ($this->requiredDirs as $dir) {
            if (!is_dir("$themeDir/$dir")) {
                $issues[] = "Missing directory: $dir";
            }
        }

        foreach ($this->requiredFiles as $file) {
            if (!file_exists("$themeDir/$file")) {
                $issues[] = "Missing file: $file";
            }
        }

        return $issues;
    }
} 