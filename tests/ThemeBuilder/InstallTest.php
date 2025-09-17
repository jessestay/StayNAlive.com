<?php
namespace StayNAlive\ThemeBuilder\Tests;

use PHPUnit\Framework\TestCase;
use StayNAlive\ThemeBuilder\Install;

class InstallTest extends TestCase {
    private string $sampleThemeDir = __DIR__ . '/../../sample-theme';
    
    protected function setUp(): void {
        // Copy StayNAlive theme files to sample-theme directory
        if (!is_dir($this->sampleThemeDir)) {
            mkdir($this->sampleThemeDir, 0755, true);
        }
    }

    /**
     * @test
     * Story: Theme Structure
     * AC: Verifies required directories exist
     */
    public function itValidatesRequiredDirectories(): void {
        $installer = new Install(['source_dir' => $this->sampleThemeDir]);
        $result = $installer->validateThemeStructure();
        
        $this->assertTrue($result);
        $this->assertDirectoryExists($this->sampleThemeDir . '/templates');
        $this->assertDirectoryExists($this->sampleThemeDir . '/parts');
        $this->assertDirectoryExists($this->sampleThemeDir . '/patterns');
    }

    /**
     * @test
     * Story: Theme Structure
     * AC: Validates file structure
     */
    public function itValidatesRequiredFiles(): void {
        $installer = new Install(['source_dir' => $this->sampleThemeDir]);
        $result = $installer->validateThemeStructure();
        
        $this->assertTrue($result);
        $this->assertFileExists($this->sampleThemeDir . '/style.css');
        $this->assertFileExists($this->sampleThemeDir . '/theme.json');
        $this->assertFileExists($this->sampleThemeDir . '/functions.php');
    }

    /**
     * @test
     * Story: Theme Analysis
     * AC: Extracts color schemes
     */
    public function itExtractsColorScheme(): void {
        $installer = new Install([
            'source_dir' => $this->sampleThemeDir,
            'target_url' => 'https://staynalive.com'
        ]);
        
        $analysis = $installer->analyzeTargetSite();
        $this->assertArrayHasKey('colors', $analysis);
        $this->assertNotEmpty($analysis['colors']);
    }

    /**
     * @test
     * Story: Theme Analysis
     * AC: Identifies typography
     */
    public function itIdentifiesTypography(): void {
        $installer = new Install([
            'source_dir' => $this->sampleThemeDir,
            'target_url' => 'https://staynalive.com'
        ]);
        
        $analysis = $installer->analyzeTargetSite();
        $this->assertArrayHasKey('typography', $analysis);
        $this->assertArrayHasKey('families', $analysis['typography']);
    }

    protected function tearDown(): void {
        // Clean up sample theme directory
        if (is_dir($this->sampleThemeDir)) {
            $this->removeDirectory($this->sampleThemeDir);
        }
    }

    private function removeDirectory(string $dir): void {
        if (is_dir($dir)) {
            $objects = scandir($dir);
            foreach ($objects as $object) {
                if ($object !== "." && $object !== "..") {
                    if (is_dir($dir . "/" . $object)) {
                        $this->removeDirectory($dir . "/" . $object);
                    } else {
                        unlink($dir . "/" . $object);
                    }
                }
            }
            rmdir($dir);
        }
    }
} 