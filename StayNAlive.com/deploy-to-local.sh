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
        $templates = get_block_templates();
        $template_slugs = array_map(function($tpl) { 
            return $tpl->slug; 
        }, $templates);
        
        $required_templates = array("front-page", "index");
        
        foreach ($required_templates as $template) {
            if (!in_array($template, $template_slugs)) {
                echo "\033[0;31mERROR: Required template $template not registered\033[0m\n";
                exit(1);
            }
        }
        
        echo "\033[0;32mTemplate registration verification passed\033[0m\n";
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

    echo -e "${GREEN}WordPress settings verified${NC}"
}

# Deploy theme
deploy_theme() {
    echo -e "${BLUE}Deploying theme to Local site...${NC}"
    
    # Verify template locations
    TEMPLATES_DIR="templates"
    if [[ ! -d "$TEMPLATES_DIR" ]]; then
        echo -e "${RED}Templates directory not found${NC}"
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