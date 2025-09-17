<?php
namespace StayNAlive\ThemeBuilder\Tests;

use PHPUnit\Framework\TestCase;
use StayNAlive\ThemeBuilder\StyleAnalyzer;

class StyleAnalyzerTest extends TestCase {
    private StyleAnalyzer $analyzer;

    protected function setUp(): void {
        $this->analyzer = new StyleAnalyzer();
    }

    public function testExtractsColors(): void {
        $css = <<<CSS
        .header { background: #fff; }
        .footer { color: #123456; }
        CSS;

        $colors = $this->analyzer->extractColors($css);
        
        $this->assertContains('#fff', $colors);
        $this->assertContains('#123456', $colors);
    }

    public function testExtractsFonts(): void {
        $css = <<<CSS
        body { font-family: Arial, sans-serif; }
        .title { font-family: "Open Sans"; }
        CSS;

        $fonts = $this->analyzer->extractFonts($css);
        
        $this->assertContains('Arial, sans-serif', $fonts);
        $this->assertContains('"Open Sans"', $fonts);
    }

    public function testExtractsSizes(): void {
        $css = <<<CSS
        body { 
            font-size: 16px;
            margin: 20px;
            padding: 1rem;
        }
        .title { 
            font-size: 2em;
            margin: 1.5rem 0;
        }
        CSS;

        $sizes = $this->analyzer->extractSizes($css);
        
        $this->assertContains('16px', $sizes['font']);
        $this->assertContains('2em', $sizes['font']);
        $this->assertContains('20px', $sizes['spacing']);
        $this->assertContains('1rem', $sizes['spacing']);
    }

    public function testGeneratesThemeJson(): void {
        $colors = ['#fff', '#123'];
        $fonts = ['Arial, sans-serif'];
        $sizes = [
            'font' => ['16px', '2em'],
            'spacing' => ['1rem']
        ];

        $json = $this->analyzer->generateThemeJson($colors, $fonts, $sizes);
        
        $this->assertEquals(2, $json['version']);
        $this->assertCount(2, $json['settings']['color']['palette']);
        $this->assertCount(1, $json['settings']['typography']['fontFamilies']);
        $this->assertCount(2, $json['settings']['typography']['fontSizes']);
    }
} 