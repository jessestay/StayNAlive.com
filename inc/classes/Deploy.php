<?php
namespace StayNAlive\ThemeBuilder;

use Exception;
use ZipArchive;
use DOMDocument;
use GuzzleHttp\Client;
use GuzzleHttp\Exception\GuzzleException;

class Deploy {
    private string $themeZip;
    private string $localUrl = 'http://localhost:10000';
    private string $targetUrl = '';
    private string $localRoot;
    private Client $client;
    
    // From our shell script experience
    private array $healthChecks = [
        'php' => [
            'error_log' => 'wp-content/debug.log',
            'error_reporting' => E_ALL,
            'display_errors' => 1
        ],
        'wordpress' => [
            'rest_api' => '/wp-json/wp/v2',
            'themes_endpoint' => '/wp-json/wp/v2/themes',
            'health_endpoint' => '/wp-json/wp-site-health/v1/tests'
        ]
    ];

    public function __construct(array $config = []) {
        $this->themeZip = $config['theme_zip'] ?? 'theme.zip';
        $this->localUrl = rtrim($config['local_url'] ?? $this->localUrl, '/');
        $this->targetUrl = rtrim($config['target_url'] ?? $this->targetUrl, '/');
        
        // Determine Local by Flywheel root path
        if (PHP_OS_FAMILY === 'Windows') {
            $user = getenv('USERNAME') ?: getenv('USER') ?: get_current_user();
            $this->localRoot = "C:/Users/{$user}/Local Sites";
        } else {
            $this->localRoot = getenv('HOME') . '/Local Sites';
        }

        $this->client = new Client([
            'timeout' => 30,
            'verify' => false // Local often uses self-signed certs
        ]);
    }

    public function deployToLocal(): bool {
        echo "Starting deployment to Local...\n";

        // Verify zip exists
        if (!file_exists($this->themeZip)) {
            throw new Exception("Theme zip not found: {$this->themeZip}");
        }

        // Extract site name from Local URL
        $siteName = $this->extractSiteName();
        $themesDir = "{$this->localRoot}/{$siteName}/app/public/wp-content/themes";
        
        // Create backup
        $this->backupExistingTheme($themesDir);

        // Deploy theme
        echo "Deploying theme to Local...\n";
        $zip = new ZipArchive();
        if ($zip->open($this->themeZip) !== true) {
            throw new Exception("Cannot open theme zip");
        }

        // Extract theme
        $zip->extractTo($themesDir);
        $zip->close();

        // Verify installation
        if (!$this->verifyInstallation()) {
            throw new Exception("Theme installation verification failed");
        }

        // Check WordPress health
        $healthIssues = $this->checkWordPressHealth();
        if (!empty($healthIssues)) {
            echo "WARNING: Health check issues found:\n";
            foreach ($healthIssues as $issue) {
                echo "- {$issue}\n";
            }
        }

        return true;
    }

    public function compareWithTarget(): array {
        if (!$this->targetUrl) {
            return ['warning' => 'No target URL specified'];
        }

        echo "Comparing with target site...\n";
        
        try {
            // Get target site content
            $targetResponse = $this->client->get($this->targetUrl);
            $targetHtml = $targetResponse->getBody()->getContents();
            
            // Get local site content
            $localResponse = $this->client->get($this->localUrl);
            $localHtml = $localResponse->getBody()->getContents();

            // Parse both DOMs
            $targetDom = new DOMDocument();
            $localDom = new DOMDocument();
            @$targetDom->loadHTML($targetHtml);
            @$localDom->loadHTML($localHtml);

            return $this->analyzeDifferences($targetDom, $localDom);

        } catch (GuzzleException $e) {
            throw new Exception("Failed to fetch site content: " . $e->getMessage());
        }
    }

    private function extractSiteName(): string {
        if (preg_match('/\/\/([^.]+)\./', $this->localUrl, $matches)) {
            return $matches[1];
        }
        throw new Exception("Could not extract site name from URL");
    }

    private function backupExistingTheme(string $themesDir): void {
        $themeName = pathinfo($this->themeZip, PATHINFO_FILENAME);
        $existingTheme = "{$themesDir}/{$themeName}";
        
        if (is_dir($existingTheme)) {
            $backupName = $themeName . '_backup_' . date('Ymd_His');
            if (!rename($existingTheme, "{$themesDir}/{$backupName}")) {
                throw new Exception("Failed to create backup");
            }
            echo "Created backup: {$backupName}\n";
        }
    }

    private function verifyInstallation(): bool {
        echo "Verifying installation...\n";
        
        try {
            // Check theme files
            $response = $this->client->get("{$this->localUrl}/wp-json/wp/v2/themes");
            $themes = json_decode($response->getBody(), true);
            
            $themeName = pathinfo($this->themeZip, PATHINFO_FILENAME);
            $themeFound = false;
            
            foreach ($themes as $theme) {
                if ($theme['stylesheet'] === $themeName) {
                    $themeFound = true;
                    break;
                }
            }

            if (!$themeFound) {
                throw new Exception("Theme not found in WordPress");
            }

            // Check for PHP errors
            $debugLog = "{$this->localRoot}/{$this->extractSiteName()}/app/public/wp-content/debug.log";
            if (file_exists($debugLog)) {
                $errors = file_get_contents($debugLog);
                if (preg_match('/PHP (Warning|Error|Fatal error)/', $errors)) {
                    throw new Exception("PHP errors found in debug.log");
                }
            }

            return true;

        } catch (GuzzleException $e) {
            throw new Exception("Installation verification failed: " . $e->getMessage());
        }
    }

    private function checkWordPressHealth(): array {
        $issues = [];
        
        try {
            // Check REST API
            $response = $this->client->get("{$this->localUrl}/wp-json");
            if ($response->getStatusCode() !== 200) {
                $issues[] = "REST API not responding properly";
            }

            // Check theme activation
            $themesResponse = $this->client->get("{$this->localUrl}/wp-json/wp/v2/themes");
            $themes = json_decode($themesResponse->getBody(), true);
            $themeName = pathinfo($this->themeZip, PATHINFO_FILENAME);
            
            $themeActive = false;
            foreach ($themes as $theme) {
                if ($theme['stylesheet'] === $themeName && $theme['status'] === 'active') {
                    $themeActive = true;
                    break;
                }
            }

            if (!$themeActive) {
                $issues[] = "Theme is not active";
            }

            // Check for critical errors
            $healthResponse = $this->client->get("{$this->localUrl}/wp-json/wp-site-health/v1/tests/background-updates");
            $health = json_decode($healthResponse->getBody(), true);
            
            if (isset($health['status']) && $health['status'] === 'critical') {
                $issues[] = "Critical site health issues found";
            }

        } catch (GuzzleException $e) {
            $issues[] = "Health check failed: " . $e->getMessage();
        }

        return $issues;
    }

    private function analyzeDifferences(DOMDocument $targetDom, DOMDocument $localDom): array {
        $differences = [];
        
        // Compare block structures
        $targetBlocks = $this->extractBlockStructure($targetDom);
        $localBlocks = $this->extractBlockStructure($localDom);
        
        $differences['missing_blocks'] = array_diff_key($targetBlocks, $localBlocks);
        $differences['extra_blocks'] = array_diff_key($localBlocks, $targetBlocks);
        
        // Compare layouts
        $differences['layout'] = $this->compareLayouts($targetDom, $localDom);
        
        // Compare styles
        $differences['styles'] = $this->compareStyles($targetDom, $localDom);
        
        return $differences;
    }

    private function extractBlockStructure(DOMDocument $dom): array {
        $blocks = [];
        $xpath = new \DOMXPath($dom);
        
        // Find WordPress blocks
        $blockNodes = $xpath->query("//*[contains(@class, 'wp-block-')]");
        foreach ($blockNodes as $node) {
            $classes = $node->getAttribute('class');
            if (preg_match('/wp-block-([^\s]+)/', $classes, $matches)) {
                $blockType = $matches[1];
                $blocks[$blockType] = true;
            }
        }
        
        return $blocks;
    }

    private function compareLayouts(DOMDocument $targetDom, DOMDocument $localDom): array {
        $differences = [];
        
        // Compare container widths
        $targetContainers = $this->extractContainerWidths($targetDom);
        $localContainers = $this->extractContainerWidths($localDom);
        
        foreach ($targetContainers as $selector => $width) {
            if (!isset($localContainers[$selector]) || $localContainers[$selector] !== $width) {
                $differences[] = "Container width mismatch: {$selector}";
            }
        }
        
        return $differences;
    }

    private function compareStyles(DOMDocument $targetDom, DOMDocument $localDom): array {
        $differences = [];
        
        // Compare colors
        $targetColors = $this->extractColors($targetDom);
        $localColors = $this->extractColors($localDom);
        
        $differences['colors'] = array_diff($targetColors, $localColors);
        
        // Compare typography
        $targetFonts = $this->extractFonts($targetDom);
        $localFonts = $this->extractFonts($localDom);
        
        $differences['fonts'] = array_diff($targetFonts, $localFonts);
        
        return $differences;
    }

    private function extractContainerWidths(DOMDocument $dom): array {
        $widths = [];
        $xpath = new \DOMXPath($dom);
        
        $containers = $xpath->query("//*[contains(@class, 'container')]");
        foreach ($containers as $container) {
            $style = $container->getAttribute('style');
            if (preg_match('/width:\s*(\d+)/', $style, $matches)) {
                $widths[$container->getAttribute('class')] = $matches[1];
            }
        }
        
        return $widths;
    }

    private function extractColors(DOMDocument $dom): array {
        $colors = [];
        $xpath = new \DOMXPath($dom);
        
        $styles = $xpath->query('//style');
        foreach ($styles as $style) {
            preg_match_all('/#([a-f0-9]{3}){1,2}\b/i', $style->nodeValue, $matches);
            $colors = array_merge($colors, $matches[0]);
        }
        
        return array_unique($colors);
    }

    private function extractFonts(DOMDocument $dom): array {
        $fonts = [];
        $xpath = new \DOMXPath($dom);
        
        $styles = $xpath->query('//style');
        foreach ($styles as $style) {
            preg_match_all('/font-family:\s*([^;]+);/', $style->nodeValue, $matches);
            $fonts = array_merge($fonts, array_map('trim', $matches[1]));
        }
        
        return array_unique($fonts);
    }
} 