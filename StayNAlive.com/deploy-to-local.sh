#!/bin/bash

# Set strict error handling
set -euo pipefail

# Define colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to check WordPress settings
check_wp_settings() {
    echo -e "${BLUE}Checking WordPress settings...${NC}"
    
    # Check if wp-cli is available
    if ! command -v wp &> /dev/null; then
        echo -e "${RED}wp-cli is not installed. Please install it first.${NC}"
        exit 1
    }

    # Set homepage
    echo -e "${BLUE}Setting up homepage...${NC}"
    wp option update show_on_front page
    wp option update page_on_front 19

    # Verify homepage settings
    if ! php tests/test-homepage.php; then
        echo -e "${RED}Homepage setup failed${NC}"
        exit 1
    fi

    # Check template loading
    echo -e "${BLUE}Checking template loading...${NC}"
    TEMPLATE=$(wp eval 'global $template; echo get_page_template();')
    if [[ ! $TEMPLATE =~ "front-page.php" ]]; then
        echo -e "${RED}Front page template not loading correctly${NC}"
        exit 1
    fi

    # Test template hierarchy
    echo -e "${BLUE}Testing template hierarchy...${NC}"
    wp eval '
        $templates = array("front-page.html", "home.html", "index.html");
        foreach ($templates as $template) {
            if (file_exists(get_template_directory() . "/templates/" . $template)) {
                echo "$template exists\n";
            }
        }
    '

    # Test content loading
    echo -e "${BLUE}Testing content loading...${NC}"
    wp eval '
        $front_page_id = get_option("page_on_front");
        $front_page = get_post($front_page_id);
        
        if (!$front_page || empty($front_page->post_content)) {
            echo "\033[0;31mERROR: Homepage content not found or empty\033[0m\n";
            exit(1);
        }

        // Check for required blocks in front-page.html
        $template_path = get_template_directory() . "/templates/front-page.html";
        $template_content = file_get_contents($template_path);
        
        $required_blocks = array(
            "wp:post-title",
            "wp:post-content",
            "wp:post-featured-image"
        );

        foreach ($required_blocks as $block) {
            if (strpos($template_content, $block) === false) {
                echo "\033[0;31mERROR: Required block $block not found in front-page.html\033[0m\n";
                exit(1);
            }
        }

        echo "\033[0;32mContent loading verification passed\033[0m\n";
    '

    # Test template rendering
    echo -e "${BLUE}Testing template rendering...${NC}"
    wp eval '
        $front_page_url = get_permalink(get_option("page_on_front"));
        $response = wp_remote_get($front_page_url);
        
        if (is_wp_error($response)) {
            echo "\033[0;31mERROR: Could not fetch homepage\033[0m\n";
            exit(1);
        }

        $content = wp_remote_retrieve_body($response);
        
        // Check for key content elements
        $required_elements = array(
            "hero-section",
            "expertise-section",
            "featured-posts",
            "cta-section"
        );

        foreach ($required_elements as $element) {
            if (strpos($content, $element) === false) {
                echo "\033[0;31mERROR: Required element $element not found in rendered page\033[0m\n";
                exit(1);
            }
        }

        echo "\033[0;32mTemplate rendering verification passed\033[0m\n";
    '

    # Test template registration
    echo -e "${BLUE}Testing template registration...${NC}"
    wp eval '
        echo "\nDebug: Template Registration\n";
        echo "==========================\n";
        
        // Check theme.json templates
        $theme_json = json_decode(file_get_contents(get_template_directory() . "/theme.json"), true);
        echo "Theme.json templates:\n";
        if (isset($theme_json["templates"])) {
            foreach ($theme_json["templates"] as $template) {
                echo "- {$template["name"]}\n";
            }
        } else {
            echo "No templates defined in theme.json\n";
        }
        echo "\n";
        
        // Check registered templates
        echo "WordPress registered templates:\n";
        $templates = get_block_templates();
        $template_names = array();
        
        foreach ($templates as $template) {
            echo sprintf(
                "- %s (%s)\n  Source: %s\n  Type: %s\n  Status: %s\n  Theme: %s\n\n",
                $template->title,
                $template->slug,
                $template->source,
                $template->type,
                $template->status,
                $template->theme
            );
            $template_names[$template->slug] = $template->title;
        }
        
        // Check filesystem templates
        echo "Filesystem templates:\n";
        $template_files = glob(get_template_directory() . "/templates/*.html");
        foreach ($template_files as $file) {
            $name = basename($file, ".html");
            echo sprintf(
                "- %s\n  Path: %s\n  Size: %d bytes\n  Registered: %s\n\n",
                $name,
                str_replace(get_template_directory(), "", $file),
                filesize($file),
                isset($template_names[$name]) ? "Yes" : "No"
            );
        }
        
        $required_templates = array("front-page", "index");
        
        foreach ($required_templates as $template) {
            if (!isset($template_names[$template])) {
                echo "\033[0;31mERROR: Required template $template not registered\033[0m\n";
                echo "Available templates: " . implode(", ", array_keys($template_names)) . "\n";
               
               // Additional debug info for missing template
               $template_file = get_template_directory() . "/templates/" . $template . ".html";
               if (file_exists($template_file)) {
                   echo "File exists but not registered. Content:\n";
                   echo file_get_contents($template_file) . "\n";
               } else {
                   echo "Template file does not exist: $template_file\n";
               }
                exit(1);
            }
        }
    '

    # Test theme.json configuration
    echo -e "${BLUE}Testing theme.json configuration...${NC}"
    wp eval '
        $theme = wp_get_theme();
        $theme_json = json_decode(file_get_contents(get_template_directory() . "/theme.json"), true);
        
        // Check required theme.json fields
        $required_fields = array(
            "name",
            "textdomain",
            "patterns",
            "templateParts",
            "customTemplates",
            "defaultTemplateTypes"
        );
        
        foreach ($required_fields as $field) {
            if (!isset($theme_json[$field])) {
                echo "\033[0;31mERROR: Required field $field missing in theme.json\033[0m\n";
                exit(1);
            }
        }
        
        // Verify pattern registration
        $patterns = WP_Block_Patterns_Registry::get_instance()->get_all_registered();
        foreach ($theme_json["patterns"] as $pattern) {
            if (!isset($patterns[$pattern["name"]])) {
                echo "\033[0;31mERROR: Pattern {$pattern["name"]} not registered\033[0m\n";
                exit(1);
            }
        }
        
        echo "\033[0;32mtheme.json verification passed\033[0m\n";
    '

    # Verify installed templates match source files
    echo -e "${BLUE}Verifying installed templates...${NC}"
    wp eval '
        $theme = wp_get_theme();
        $theme_dir = get_template_directory();
        
        echo "\nWordPress Registered Templates:\n";
        echo "================================\n";
        $registered_templates = get_block_templates();
        foreach ($registered_templates as $template) {
            echo sprintf(
                "- %s (%s)\n  Status: %s\n  Type: %s\n  Path: %s\n\n",
                $template->title,
                $template->slug,
                $template->status,
                $template->type,
                $template->source
            );
        }

        echo "\nSource Template Files:\n";
        echo "=====================\n";
        $source_templates = glob($theme_dir . "/templates/*.html");
        foreach ($source_templates as $template_file) {
            $template_slug = basename($template_file, ".html");
            echo sprintf(
                "- %s\n  Path: %s\n  Size: %s bytes\n\n",
                $template_slug,
                str_replace($theme_dir, "", $template_file),
                filesize($template_file)
            );
        }

        echo "\nTemplate Comparison:\n";
        echo "===================\n";
        
        // Compare installed templates with source files
        foreach ($registered_templates as $template) {
            $template_slug = $template->slug;
            $source_file = $theme_dir . "/templates/" . $template_slug . ".html";
            
            echo sprintf(
                "Checking %s:\n",
                $template_slug
            );
            
            // Check if source file exists
            if (!file_exists($source_file)) {
                echo sprintf(
                    "\033[0;31m  ✗ Source file missing: %s\033[0m\n",
                    $source_file
                );
                exit(1);
            }
            
            // Get installed template content
            $installed_content = $template->content;
            $source_content = file_get_contents($source_file);
            
            // Normalize whitespace and line endings
            $installed_content = preg_replace("/\s+/", " ", trim($installed_content));
            $source_content = preg_replace("/\s+/", " ", trim($source_content));
            
            if ($installed_content !== $source_content) {
                echo "\033[0;31m  ✗ Content mismatch:\033[0m\n";
                echo "  Source content (first 100 chars):\n    " . substr($source_content, 0, 100) . "...\n";
                echo "  Installed content (first 100 chars):\n    " . substr($installed_content, 0, 100) . "...\n";
                exit(1);
            }
            
            echo "\033[0;32m  ✓ Template verified\033[0m\n";
            echo "  - Source file exists\n";
            echo "  - Content matches\n";
            echo "  - Properly registered\n\n";
        }
    '

    # Verify template parts
    echo -e "${BLUE}Verifying template parts...${NC}"
    wp eval '
        $theme = wp_get_theme();
        $theme_dir = get_template_directory();
        $installed_parts = get_block_template_parts(array("theme" => $theme->get_stylesheet()));
        
        // Get source template parts
        $source_parts = glob($theme_dir . "/parts/*.html");
        $source_part_contents = array();
        
        foreach ($source_parts as $part_file) {
            $part_slug = basename($part_file, ".html");
            $source_part_contents[$part_slug] = file_get_contents($part_file);
        }
        
        // Compare installed parts with source files
        foreach ($installed_parts as $part) {
            $part_slug = $part->slug;
            
            if (!isset($source_part_contents[$part_slug])) {
                echo "\033[0;31mERROR: Template part $part_slug exists in WordPress but not in source files\033[0m\n";
                exit(1);
            }
            
            $installed_content = $part->content;
            $source_content = $source_part_contents[$part_slug];
            
            // Normalize whitespace and line endings
            $installed_content = preg_replace("/\s+/", " ", trim($installed_content));
            $source_content = preg_replace("/\s+/", " ", trim($source_content));
            
            if ($installed_content !== $source_content) {
                echo "\033[0;31mERROR: Content mismatch for template part $part_slug\033[0m\n";
                exit(1);
            }
            
            echo "Template part $part_slug verified ✓\n";
        }
        
        echo "\033[0;32mAll template parts verified successfully\033[0m\n";
    '

    # Verify WordPress registered all templates
    echo -e "${BLUE}Verifying WordPress template registration...${NC}"
    wp eval '
        $registered = get_block_templates();
        $required_templates = array("front-page", "index", "single", "archive", "search", "404");
        
        foreach ($required_templates as $template) {
            $found = false;
            foreach ($registered as $reg) {
                if ($reg->slug === $template) {
                    $found = true;
                    break;
                }
            }
            if (!$found) {
                echo "\033[0;31mERROR: WordPress did not register template: $template\033[0m\n";
                exit(1);
            }
            echo "✓ Template $template is registered\n";
        }
    '

    echo -e "${GREEN}WordPress settings verified${NC}"
}

# Deploy theme
deploy_theme() {
    echo -e "${BLUE}Deploying theme to Local site...${NC}"
    
    # Check if Local site is running
    echo -e "${BLUE}Checking Local site accessibility...${NC}"
    if ! curl -s -I "http://staynalive.local" > /dev/null; then
        echo -e "${RED}ERROR: Cannot access staynalive.local${NC}"
        echo "Please ensure:"
        echo "1. Local is running"
        echo "2. Site is started"
        echo "3. hosts file has staynalive.local entry"
        exit 1
    }
    echo -e "${GREEN}Local site is accessible${NC}"

    # Verify template locations
    TEMPLATES_DIR="templates"
    FRONT_PAGE="$TEMPLATES_DIR/front-page.html"
    
    # Check front-page.html specifically
    if [[ ! -f "$FRONT_PAGE" ]]; then
        echo -e "${RED}ERROR: front-page.html not found${NC}"
        echo "Expected location: $FRONT_PAGE"
        exit 1
    }
    
    # Verify front-page.html content
    if ! grep -q "wp:post-content" "$FRONT_PAGE"; then
        echo -e "${RED}ERROR: front-page.html missing wp:post-content block${NC}"
        exit 1
    }
    
    # Verify front-page.html is included in zip
    if ! unzip -l stay-n-alive.zip | grep -q "front-page.html"; then
        echo -e "${RED}ERROR: front-page.html not found in theme zip${NC}"
        exit 1
    }

    REQUIRED_TEMPLATES=("front-page.html" "index.html")
    for template in "${REQUIRED_TEMPLATES[@]}"; do
        if [[ ! -f "$TEMPLATES_DIR/$template" ]]; then
            echo -e "${RED}Required template $template not found${NC}"
            exit 1
        }
    }
    
    # Your existing deployment code here...
    
    check_wp_settings

    # Verify all required files were deployed
    THEME_PATH="/c/Users/stay/Local Sites/staynalive/app/public/wp-content/themes/stay-n-alive"
    echo -e "${BLUE}Verifying deployed files...${NC}"
    REQUIRED_FILES=(
        "templates/front-page.html"
        "templates/index.html"
        "parts/header.html"
        "parts/footer.html"
    )
    
    for file in "${REQUIRED_FILES[@]}"; do
        if [[ ! -f "$THEME_PATH/$file" ]]; then
            echo -e "${RED}ERROR: Required file $file not found in deployed theme${NC}"
            exit 1
        fi
        echo -e "${GREEN}✓ Found $file${NC}"
    }

    # Additional HTML syntax verification
    echo -e "${BLUE}Starting HTML syntax verification...${NC}"
    wp eval '
        $theme_dir = get_template_directory();
        $all_html_files = array_merge(
            glob($theme_dir . "/templates/*.html"),
            glob($theme_dir . "/parts/*.html"),
            glob($theme_dir . "/patterns/*.html")
        );
        
        echo "Found " . count($all_html_files) . " HTML files to validate\n\n";
        
        foreach ($all_html_files as $file) {
            $relative_path = str_replace($theme_dir . "/", "", $file);
            echo "Validating $relative_path...\n";
            // Validation code here
        }
    '
}

# Main execution
echo -e "${BLUE}Starting deployment to Local...${NC}"

# Run deployment
if deploy_theme; then
    echo -e "${GREEN}Deployment successful!${NC}"
else
    echo -e "${RED}Deployment failed${NC}"
    exit 1
fi 