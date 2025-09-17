<?php
namespace StayNAlive\ThemeBuilder\Tests;

use PHPUnit\Framework\TestCase;
use StayNAlive\ThemeBuilder\ThemeComparator;

class ThemeComparatorTest extends TestCase {
    private ThemeComparator $comparator;
    private string $testDir;

    protected function setUp(): void {
        $this->comparator = new ThemeComparator();
        $this->testDir = sys_get_temp_dir() . '/theme-test-' . uniqid();
        mkdir($this->testDir);
    }

    public function testComparesTemplates(): void {
        // Create test templates
        file_put_contents(
            $this->testDir . '/source.html',
            '<!-- wp:paragraph -->Content<!-- /wp:paragraph -->'
        );
        file_put_contents(
            $this->testDir . '/target.html',
            '<!-- wp:heading -->Title<!-- /wp:heading -->'
        );

        $result = $this->comparator->compareTemplates(
            $this->testDir . '/source.html',
            $this->testDir . '/target.html'
        );

        $this->assertContains('heading', $result['missing']);
        $this->assertContains('paragraph', $result['extra']);
    }

    protected function tearDown(): void {
        system('rm -rf ' . escapeshellarg($this->testDir));
    }
} 