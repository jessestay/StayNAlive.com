<?php
namespace StayNAlive\ThemeBuilder\Tests;

use PHPUnit\Framework\TestCase;
use StayNAlive\ThemeBuilder\Deploy;

class DeployTest extends TestCase {
    private string $themeZip = __DIR__ . '/../../theme.zip';
    
    /**
     * @test
     * Story: Local Deployment
     * AC: Creates theme backup
     */
    public function itCreatesThemeBackup(): void {
        $deployer = new Deploy([
            'theme_zip' => $this->themeZip,
            'local_url' => 'http://staynalive.local'
        ]);
        
        $result = $deployer->backupExistingTheme('/mock/themes/dir');
        $this->assertTrue($result);
    }

    /**
     * @test
     * Story: Local Deployment
     * AC: Verifies installation
     */
    public function itVerifiesInstallation(): void {
        $deployer = new Deploy([
            'theme_zip' => $this->themeZip,
            'local_url' => 'http://staynalive.local'
        ]);
        
        $result = $deployer->verifyInstallation();
        $this->assertTrue($result);
    }

    /**
     * @test
     * Story: Theme Comparison
     * AC: Compares block structures
     */
    public function itComparesBlockStructures(): void {
        $deployer = new Deploy([
            'theme_zip' => $this->themeZip,
            'local_url' => 'http://staynalive.local',
            'target_url' => 'https://staynalive.com'
        ]);
        
        $comparison = $deployer->compareWithTarget();
        $this->assertArrayHasKey('missing_blocks', $comparison);
        $this->assertArrayHasKey('extra_blocks', $comparison);
    }
} 