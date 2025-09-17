# Installation Guide (Windows/Bash)

## Prerequisites

1. Install PHP ZIP Extension:
```bash
# Check current PHP version
php -v

# Install PHP ZIP extension
# For XAMPP: Enable php_zip.dll in php.ini
# For standalone PHP: 
sudo apt-get install php-zip   # WSL/Linux
# Or for Windows:
# Edit php.ini and uncomment:
# extension=zip
```

2. Verify PHP Extensions:
```bash
# Show loaded extensions
php -m | grep zip
# Should show 'zip'

# Show PHP info including .ini location
php --ini
```

3. Update Composer Dependencies:
```bash
# Remove lock file to start fresh
rm composer.lock

# Install with platform requirements ignored for now
composer install --ignore-platform-reqs
```

## Quick Start

1. Clone and setup:
```bash
git clone <repo>
cd staynalive-theme-builder

# Install dependencies (with platform check override)
composer install --ignore-platform-reqs

# Make CLI executable 
chmod +x bin/theme-builder
```

2. Test installation:
```bash
# Run unit tests
composer test

# Try analysis
composer analyze -- --source-dir=./sample-theme
```

## Common Issues

1. PHP ZIP Extension Missing:
- Edit php.ini (location from php --ini)
- Uncomment: extension=zip
- Restart PHP/terminal

2. Composer Plugin Trust:
```bash
# Add to composer.json (already done)
{
    "config": {
        "allow-plugins": {
            "dealerdirect/phpcodesniffer-composer-installer": true
        }
    }
}
```

3. Lock File Mismatch:
```bash
# Regenerate lock file
composer update --ignore-platform-reqs
``` 