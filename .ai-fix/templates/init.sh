#!/bin/bash

# Create project structure
mkdir -p .ai-fix/{node,php,rust,python}/fixes
mkdir -p .ai-fix/patterns

# Create default config
cat > .ai-fix.config.json << 'EOL'
{
    "project_type": "auto",
    "auto_fix": true,
    "backup": true,
    "patterns_path": ".ai-fix/patterns",
    "fixes_path": ".ai-fix/fixes"
}
EOL

# Create gitignore
echo ".ai-fix/backups/" >> .gitignore 