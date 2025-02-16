# Theme Translation Files

This directory contains translation files for the Stay N Alive theme.

## Translation Files

- `staynalive.pot` - Template file containing all translatable strings
- `{locale}.po` - Translation source file for each language
- `{locale}.mo` - Compiled translation file for each language

## How to Translate

1. **Using Poedit (Recommended)**
   - Download Poedit from https://poedit.net/
   - Open the `staynalive.pot` file
   - Create a new translation for your language
   - Save as `{locale}.po` (e.g., `fr_FR.po` for French)
   - Poedit will automatically generate the `.mo` file

2. **Using WordPress.org Translation Platform**
   - Visit https://translate.wordpress.org/
   - Find the "Stay N Alive" theme
   - Contribute translations for your language
   - Download the generated files

## Block Editor Strings

This theme uses the block editor, so some strings come from:
- Block patterns
- Theme JSON
- Block templates
- Block styles

These are automatically extracted to the POT file.

## Useful Links

- [WordPress Polyglots Team](https://make.wordpress.org/polyglots/teams/)
- [Theme Localization](https://developer.wordpress.org/themes/functionality/localization/)
- [Block Theme Translation](https://developer.wordpress.org/block-editor/how-to-guides/internationalization/)
- [Text Domain Documentation](https://developer.wordpress.org/themes/functionality/internationalization/)

## Notes

- The theme's text domain is 'staynalive'
- Use `esc_html__()` or `esc_attr__()` for escaping translations
- Block patterns may need manual string extraction
- Test RTL languages with the RTL stylesheet

## Getting Help

If you need help with translations:
1. Check the [WordPress Polyglots forum](https://wordpress.org/support/forum/polyglots/)
2. Open an issue on the [theme repository](https://github.com/jessestay/staynalive)
3. Contact the theme author at https://staynalive.com/contact/ 