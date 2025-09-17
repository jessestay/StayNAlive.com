# StayNAlive Theme Builder

## Quick Start

```bash
# Install dependencies
composer install

# Run tests
composer test

# Analyze theme
./bin/theme-builder --action=analyze --source-dir=./my-theme --target-url=https://staynalive.com

# Deploy to Local
./bin/theme-builder --action=deploy --output-zip=theme.zip --local-url=http://staynalive.local
```

## Directory Structure

```
staynalive-theme-builder/
├── bin/
│   └── theme-builder
├── src/
│   └── ThemeBuilder/
│       ├── Install.php
│       ├── Deploy.php
│       ├── ThemeValidator.php
│       ├── BlockAnalyzer.php
│       ├── StyleAnalyzer.php
│       └── ThemeComparator.php
├── tests/
│   └── ThemeBuilder/
│       ├── InstallTest.php
│       ├── DeployTest.php
│       └── ThemeComparatorTest.php
└── composer.json
```

## Features

- Theme Structure Validation
  - Directory structure checks
  - Required files verification
  - WordPress standards compliance

- Block Analysis
  - Pattern detection
  - Block usage statistics
  - Missing block identification

- Style Analysis
  - Color scheme extraction
  - Typography analysis
  - Layout comparison

- Local Deployment
  - Automatic backup
  - WordPress integration
  - Health checks

## Development

```bash
# Run all tests
composer test

# Analyze a theme
composer analyze -- --source-dir=./my-theme

# Deploy to Local
composer deploy -- --local-url=http://local.test
``` 