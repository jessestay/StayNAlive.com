<?php
namespace StayNAlive\ThemeBuilder;

use PHP_CodeSniffer\Runner;
use ZipArchive;
use DOMDocument;
use Exception;

class Install {
    private string $sourceDir = 'src/theme';
    private string $targetUrl = '';
    private string $outputZip = 'theme.zip';
    
    // Required theme structure from our shell script experience
    private array $requiredDirs = [
        'assets/css/base',
        'assets/css/blocks',
        'assets/css/components',
        'assets/css/compatibility',
        'assets/css/utilities',
        'assets/js',
        'inc',
        'inc/classes',
        'languages',
        'parts',
        'patterns',
        'styles',
        'templates'
    ];

    private array $requiredFiles = [
        'style.css',
        'theme.json',
        'functions.php',
        'index.php',
        'inc/theme-setup.php',
        'inc/template-loader.php',
        'inc/security.php',
        'inc/performance.php',
        'inc/social-feeds.php'
    ];

    public function __construct(array $config = []) {
        $this->sourceDir = rtrim($config['source_dir'] ?? $this->sourceDir, '/');
        $this->targetUrl = $config['target_url'] ?? $this->targetUrl;
        $this->outputZip = $config['output_zip'] ?? $this->outputZip;
    }

    public function validateThemeStructure(): bool {
        echo "Validating theme structure...\n";
        
        // Create directories
        foreach ($this->requiredDirs as $dir) {
            $fullPath = "{$this->sourceDir}/{$dir}";
            if (!is_dir($fullPath)) {
                if (!mkdir($fullPath, 0755, true)) {
                    throw new Exception("Failed to create directory: {$dir}");
                }
                // Add index.php protection
                file_put_contents("{$fullPath}/index.php", "<?php // Silence is golden.");
            }
        }

        // Check required files
        foreach ($this->requiredFiles as $file) {
            $fullPath = "{$this->sourceDir}/{$file}";
            if (!file_exists($fullPath)) {
                throw new Exception("Required file missing: {$file}");
            }
        }

        return true;
    }

    public function validateWordPressCompatibility(): array {
        echo "Validating WordPress compatibility...\n";
        
        $issues = [];
        
        // Check style.css headers
        $styleContent = file_get_contents("{$this->sourceDir}/style.css");
        $requiredHeaders = [
            'Theme Name:',
            'Theme URI:',
            'Author:',
            'Author URI:',
            'Description:',
            'Version:',
            'License:',
            'License URI:',
            'Text Domain:',
            'Tags:'
        ];

        foreach ($requiredHeaders as $header) {
            if (!preg_match("/{$header}/", $styleContent)) {
                $issues[] = "Missing {$header} in style.css";
            }
        }

        // Validate PHP files with PHPCS
        $phpcs = new Runner();
        $phpcs->config->standards = ['WordPress', 'WordPress-Core', 'WordPress-Extra'];
        $phpcs->config->files = [$this->sourceDir];
        $phpcs->config->reportWidth = 120;
        $results = $phpcs->run();
        
        if ($results > 0) {
            $issues[] = "PHPCS found {$results} issue(s)";
        }

        // Check theme.json structure
        $themeJson = json_decode(file_get_contents("{$this->sourceDir}/theme.json"), true);
        if (!isset($themeJson['version']) || $themeJson['version'] < 2) {
            $issues[] = "theme.json requires version 2 or higher";
        }

        return $issues;
    }

    public function analyzeTargetSite(): array {
        if (!$this->targetUrl) {
            return ['warning' => 'No target URL specified'];
        }

        echo "Analyzing target site: {$this->targetUrl}\n";
        
        $analysis = [];
        
        // Fetch target site content
        $html = file_get_contents($this->targetUrl);
        if (!$html) {
            throw new Exception("Could not fetch target site");
        }

        $dom = new DOMDocument();
        @$dom->loadHTML($html);

        // Analyze colors
        $analysis['colors'] = $this->extractColors($dom);
        
        // Analyze typography
        $analysis['typography'] = $this->extractTypography($dom);
        
        // Analyze layout patterns
        $analysis['patterns'] = $this->extractPatterns($dom);
        
        // Compare with current theme
        $analysis['suggestions'] = $this->generateSuggestions($analysis);

        return $analysis;
    }

    public function createThemeZip(): string {
        echo "Creating theme zip...\n";
        
        $zip = new ZipArchive();
        if ($zip->open($this->outputZip, ZipArchive::CREATE | ZipArchive::OVERWRITE) !== true) {
            throw new Exception("Cannot create zip file");
        }

        $this->addDirectoryToZip($zip, $this->sourceDir, '');
        $zip->close();

        if (!file_exists($this->outputZip)) {
            throw new Exception("Zip file was not created");
        }

        echo "Zip file created at: {$this->outputZip}\n";
        return $this->outputZip;
    }

    private function extractColors(DOMDocument $dom): array {
        // Extract colors from CSS
        $colors = [];
        $xpath = new \DOMXPath($dom);
        
        // Find style tags and analyze
        $styles = $xpath->query('//style');
        foreach ($styles as $style) {
            preg_match_all('/#([a-f0-9]{3}){1,2}\b/i', $style->nodeValue, $matches);
            $colors = array_merge($colors, $matches[0]);
        }
        
        return array_unique($colors);
    }

    private function extractTypography(DOMDocument $dom): array {
        // Extract font families and sizes
        $typography = [];
        $xpath = new \DOMXPath($dom);
        
        // Find font-family declarations
        $styles = $xpath->query('//style');
        foreach ($styles as $style) {
            preg_match_all('/font-family:\s*([^;]+);/', $style->nodeValue, $matches);
            $typography['families'] = array_merge(
                $typography['families'] ?? [],
                array_map('trim', $matches[1])
            );
        }
        
        return $typography;
    }

    private function extractPatterns(DOMDocument $dom): array {
        // Look for common block patterns
        $patterns = [];
        $xpath = new \DOMXPath($dom);
        
        // Common WordPress block patterns
        $patternSelectors = [
            'header' => '//header',
            'footer' => '//footer',
            'hero' => '//*[contains(@class, "hero")]',
            'cta' => '//*[contains(@class, "cta")]',
            'testimonials' => '//*[contains(@class, "testimonial")]'
        ];

        foreach ($patternSelectors as $type => $selector) {
            if ($xpath->query($selector)->length > 0) {
                $patterns[$type] = true;
            }
        }
        
        return $patterns;
    }

    private function generateSuggestions(array $analysis): array {
        $suggestions = [];
        
        // Compare with current theme.json
        $themeJson = json_decode(file_get_contents("{$this->sourceDir}/theme.json"), true);
        
        // Color suggestions
        if (!empty($analysis['colors'])) {
            $currentColors = $themeJson['settings']['color']['palette'] ?? [];
            $suggestions['colors'] = array_diff($analysis['colors'], array_column($currentColors, 'color'));
        }
        
        // Typography suggestions
        if (!empty($analysis['typography']['families'])) {
            $currentFonts = $themeJson['settings']['typography']['fontFamilies'] ?? [];
            $suggestions['typography'] = array_diff($analysis['typography']['families'], array_column($currentFonts, 'fontFamily'));
        }
        
        // Pattern suggestions
        foreach ($analysis['patterns'] as $pattern => $exists) {
            if ($exists && !file_exists("{$this->sourceDir}/patterns/{$pattern}.html")) {
                $suggestions['patterns'][] = "Create {$pattern}.html pattern";
            }
        }
        
        return $suggestions;
    }

    private function addDirectoryToZip(ZipArchive $zip, string $source, string $relativePath): void {
        $iterator = new \RecursiveDirectoryIterator($source);
        $files = new \RecursiveIteratorIterator($iterator);
        
        foreach ($files as $file) {
            if (!$file->isDir()) {
                $filePath = $file->getRealPath();
                $zipPath = $relativePath . substr($filePath, strlen($source));
                $zip->addFile($filePath, $zipPath);
            }
        }
    }
} 