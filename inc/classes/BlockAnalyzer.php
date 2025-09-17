<?php
namespace StayNAlive\ThemeBuilder;

class BlockAnalyzer {
    public function analyzeTemplate(string $templatePath): array {
        $content = file_get_contents($templatePath);
        $blocks = [];
        
        preg_match_all('/<!-- wp:([^\s{]+)/', $content, $matches);
        
        foreach ($matches[1] as $block) {
            $blocks[$block] = true;
        }
        
        return array_keys($blocks);
    }

    public function analyzeBlockUsage(string $templatePath): array {
        $content = file_get_contents($templatePath);
        $usage = [];
        
        preg_match_all('/<!-- wp:([^\s{]+)(?:\s+({.*}))?\s+-->/', $content, $matches, PREG_SET_ORDER);
        
        foreach ($matches as $match) {
            $blockName = $match[1];
            $attributes = isset($match[2]) ? json_decode($match[2], true) : [];
            
            if (!isset($usage[$blockName])) {
                $usage[$blockName] = [
                    'count' => 0,
                    'attributes' => []
                ];
            }
            
            $usage[$blockName]['count']++;
            if ($attributes) {
                $usage[$blockName]['attributes'][] = $attributes;
            }
        }
        
        return $usage;
    }
} 