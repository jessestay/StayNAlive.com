<?php

class CodeFixer {
    private $file;
    private $content;

    public function __construct($file) {
        $this->file = $file;
        $this->content = file_get_contents($file);
    }

    public function fixYodaConditions() {
        $this->content = preg_replace(
            '/(\$[a-zA-Z_][a-zA-Z0-9_]*)\s*([=!><]{2,3})\s*(null|true|false|\d+|"[^"]*"|\'[^\']*\')/',
            '$3 $2 $1',
            $this->content
        );
        return $this;
    }

    public function fixDocBlocks() {
        $this->content = preg_replace_callback(
            '/function\s+([a-zA-Z0-9_]+)\s*\((.*?)\)\s*{/s',
            function($matches) {
                $func_name = $matches[1];
                $params = array_filter(array_map('trim', explode(',', $matches[2])));
                
                $doc = "\n/**\n * " . ucfirst(str_replace('_', ' ', $func_name)) . ".\n *\n";
                foreach($params as $param) {
                    $type = 'mixed';
                    if (strpos($param, 'array') !== false) $type = 'array';
                    if (strpos($param, 'string') !== false) $type = 'string';
                    if (strpos($param, 'int') !== false) $type = 'int';
                    if (strpos($param, 'bool') !== false) $type = 'bool';
                    $param_name = trim(str_replace(['$', 'array', 'string', 'int', 'bool'], '', $param));
                    $doc .= " * @param {$type} \${$param_name} Parameter description.\n";
                }
                $doc .= " * @return void\n */\n";
                return $doc . "function {$matches[1]}({$matches[2]}) {";
            },
            $this->content
        );
        return $this;
    }

    public function save() {
        return file_put_contents($this->file, $this->content);
    }
}

// Get file from command line argument
$file = $argv[1];

try {
    $fixer = new CodeFixer($file);
    $fixer->fixYodaConditions()
         ->fixDocBlocks()
         ->save();
    echo "Successfully fixed {$file}\n";
} catch (Exception $e) {
    echo "Error fixing {$file}: " . $e->getMessage() . "\n";
    exit(1);
}
