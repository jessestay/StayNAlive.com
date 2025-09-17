<?php
namespace StayNAlive\ThemeBuilder;

class ThemeComparator {
    private BlockAnalyzer $blockAnalyzer;
    
    public function __construct() {
        $this->blockAnalyzer = new BlockAnalyzer();
    }

    public function compareTemplates(string $sourceTemplate, string $targetTemplate): array {
        $sourceBlocks = $this->blockAnalyzer->analyzeTemplate($sourceTemplate);
        $targetBlocks = $this->blockAnalyzer->analyzeTemplate($targetTemplate);
        
        return [
            'missing' => array_diff($targetBlocks, $sourceBlocks),
            'extra' => array_diff($sourceBlocks, $targetBlocks)
        ];
    }
} 