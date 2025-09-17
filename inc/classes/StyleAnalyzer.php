<?php
namespace StayNAlive\ThemeBuilder;

class StyleAnalyzer {
    public function extractColors(string $css): array {
        preg_match_all('/#([a-f0-9]{3}){1,2}\b/i', $css, $matches);
        $hexColors = array_unique($matches[0]);
        
        // Also extract rgb/rgba colors
        preg_match_all('/rgba?\(\s*\d+\s*,\s*\d+\s*,\s*\d+\s*(?:,\s*[\d.]+\s*)?\)/i', $css, $matches);
        $rgbColors = array_unique($matches[0]);
        
        return array_merge($hexColors, $rgbColors);
    }

    public function extractFonts(string $css): array {
        preg_match_all('/font-family:\s*([^;]+);/', $css, $matches);
        return array_unique(array_map('trim', $matches[1]));
    }

    public function extractSizes(string $css): array {
        $sizes = [];
        
        // Font sizes
        preg_match_all('/font-size:\s*([^;]+);/', $css, $matches);
        $sizes['font'] = array_unique(array_map('trim', $matches[1]));
        
        // Spacing
        preg_match_all('/margin|padding:\s*([^;]+);/', $css, $matches);
        $sizes['spacing'] = array_unique(array_map('trim', $matches[1]));
        
        return $sizes;
    }

    public function generateThemeJson(array $colors, array $fonts, array $sizes): array {
        return [
            'version' => 2,
            'settings' => [
                'color' => [
                    'palette' => array_map(function($color) {
                        return [
                            'slug' => strtolower(str_replace('#', '', $color)),
                            'color' => $color,
                            'name' => ucfirst(str_replace('#', '', $color))
                        ];
                    }, $colors)
                ],
                'typography' => [
                    'fontFamilies' => array_map(function($font) {
                        return [
                            'fontFamily' => $font,
                            'slug' => strtolower(str_replace(' ', '-', $font)),
                            'name' => $font
                        ];
                    }, $fonts),
                    'fontSizes' => array_map(function($size) {
                        return [
                            'size' => $size,
                            'slug' => strtolower(str_replace(' ', '-', $size)),
                            'name' => ucfirst($size)
                        ];
                    }, $sizes['font'])
                ]
            ]
        ];
    }
} 