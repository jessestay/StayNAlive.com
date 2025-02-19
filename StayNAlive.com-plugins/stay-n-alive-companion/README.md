# Stay N Alive Companion Plugin

A companion plugin for the Stay N Alive WordPress theme that provides essential functionality.

## Description

This plugin contains functionality that extends the Stay N Alive theme, including:
- Performance optimizations
- Security enhancements
- Social feed features

## Installation

1. Download the plugin zip file
2. Go to WordPress Admin > Plugins > Add New > Upload Plugin
3. Upload the zip file and activate the plugin
4. The plugin will automatically configure itself when activated

## Requirements

- WordPress 6.0 or higher
- Stay N Alive theme
- PHP 7.4 or higher

## Features

### Performance Optimizations
- Removes unnecessary WordPress header links
- Optimizes WordPress head output
- Improves page load performance

### Security Enhancements
- Removes WordPress version information
- Enhances basic WordPress security

### Social Feed Integration
- Adds `[social_feed]` shortcode for displaying social media feeds
- Integrates with theme social media features

## Development

### File Structure
```
stay-n-alive-companion/
├── includes/
│   ├── performance.php
│   ├── security.php
│   └── social-feeds.php
├── README.md
└── stay-n-alive-companion.php
```

### Adding New Features

1. Create a new file in the `includes` directory
2. Include the file in `stay-n-alive-companion.php`
3. Follow WordPress coding standards
4. Test thoroughly before deployment

## Support

For support, please:
1. Check the [documentation](https://staynalive.com/docs)
2. Submit issues on GitHub
3. Contact through [staynalive.com](https://staynalive.com/contact)

## License

GPL-2.0+ - see LICENSE file for details.

## Changelog

### 1.0.0
- Initial release
- Added performance optimizations
- Added security enhancements
- Added social feed shortcode 