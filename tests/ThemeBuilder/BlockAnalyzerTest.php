<?php
namespace StayNAlive\ThemeBuilder\Tests;

use PHPUnit\Framework\TestCase;
use StayNAlive\ThemeBuilder\BlockAnalyzer;

class BlockAnalyzerTest extends TestCase {
    private BlockAnalyzer $analyzer;
    private string $testDir;

    protected function setUp(): void {
        $this->analyzer = new BlockAnalyzer();
        $this->testDir = sys_get_temp_dir() . '/block-test-' . uniqid();
        mkdir($this->testDir);
    }

    public function testAnalyzesTemplate(): void {
        $template = <<<HTML
        <!-- wp:paragraph -->
        <p>Content</p>
        <!-- /wp:paragraph -->
        <!-- wp:heading {"level":2} -->
        <h2>Title</h2>
        <!-- /wp:heading -->
        HTML;

        file_put_contents($this->testDir . '/test.html', $template);

        $blocks = $this->analyzer->analyzeTemplate($this->testDir . '/test.html');
        $this->assertContains('paragraph', $blocks);
        $this->assertContains('heading', $blocks);
    }

    public function testAnalyzesBlockUsage(): void {
        $template = <<<HTML
        <!-- wp:paragraph {"align":"center"} -->
        <p>First paragraph</p>
        <!-- /wp:paragraph -->
        <!-- wp:paragraph -->
        <p>Second paragraph</p>
        <!-- /wp:paragraph -->
        HTML;

        file_put_contents($this->testDir . '/test.html', $template);

        $usage = $this->analyzer->analyzeBlockUsage($this->testDir . '/test.html');
        
        $this->assertEquals(2, $usage['paragraph']['count']);
        $this->assertCount(1, $usage['paragraph']['attributes']);
        $this->assertEquals(['align' => 'center'], $usage['paragraph']['attributes'][0]);
    }

    protected function tearDown(): void {
        system('rm -rf ' . escapeshellarg($this->testDir));
    }
} 