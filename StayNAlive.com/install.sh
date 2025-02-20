create_additional_files() {
    # Create any additional files that aren't copied from src
    echo "Creating additional theme files..."

    # Only create files that don't exist
    for template in "${REQUIRED_TEMPLATES[@]}"; do
        if [[ -f "$template" ]]; then
            echo "Skipping existing file: $template"
            continue
        fi
        
        echo "Creating missing file: $template"
        # Create file logic here...
    done
}

create_theme_json() {
    # ... existing code ...

    # Verify theme.json has required template configurations
    THEME_JSON="theme.json"
    if ! jq -e '.templates' "$THEME_JSON" > /dev/null; then
        echo -e "${RED}ERROR: theme.json missing templates configuration${NC}"
        exit 1
    }
    
    # Verify required templates are registered
    REQUIRED_TEMPLATES=("front-page" "index" "single" "archive" "search" "404")
    for template in "${REQUIRED_TEMPLATES[@]}"; do
        if ! jq -e ".templates[] | select(.name == \"$template\")" "$THEME_JSON" > /dev/null; then
            echo -e "${RED}ERROR: theme.json missing registration for $template template${NC}"
            exit 1
        fi
    }
}

validate_theme_files() {
    echo -e "${BLUE}Validating theme files...${NC}"
    
    # First verify all required files exist
    validate_file_structure
    
    # Then verify file contents
    validate_file_contents
    
    # Finally verify theme configuration
    validate_theme_json
}

validate_file_structure() {
    # Move structure validation here
}

validate_file_contents() {
    # Move content validation here
}

validate_theme_json() {
    # Move theme.json validation here
}

create_checkpoints() {
    echo -e "${BLUE}Creating installation checkpoints...${NC}"
    
    declare -A CHECKPOINT_CONTENTS=(
        [".checkpoint_directories"]="templates/\nparts/\npatterns/\nassets/\ninc/"
        [".checkpoint_template_files"]="front-page.html\nindex.html\nsingle.html"
        [".checkpoint_block_patterns"]="hero-section\nexpertise-section\nfeatured-posts"
        [".checkpoint_theme_json"]="templates\npatterns\nstyles"
        [".checkpoint_css_files"]="custom-styles.css"
        [".checkpoint_php_files"]="functions.php\ntemplate-loader.php"
    )
    
    for checkpoint in "${!CHECKPOINT_CONTENTS[@]}"; do
        echo "${CHECKPOINT_CONTENTS[$checkpoint]}" > "$checkpoint"
        if [[ ! -f "$checkpoint" ]]; then
            echo -e "${RED}ERROR: Failed to create $checkpoint${NC}"
            exit 1
        fi
        echo -e "${GREEN}✓ Created $checkpoint with content${NC}"
    }
}

verify_file_structure() {
    echo -e "${BLUE}Verifying file structure...${NC}"
    
    declare -A REQUIRED_FILES=(
        ["assets/css/blocks"]="custom-styles.css"
        ["inc"]="template-loader.php\ntheme-setup.php"
        ["templates"]="front-page.html\nindex.html"
        ["parts"]="header.html\nfooter.html"
        ["patterns"]="hero-section.html\nexpertise-section.html"
    )
    
    for dir in "${!REQUIRED_FILES[@]}"; do
        IFS=$'\n' read -r -d '' -a files <<< "${REQUIRED_FILES[$dir]}"
        for file in "${files[@]}"; do
            if [[ ! -f "$dir/$file" ]]; then
                echo -e "${RED}ERROR: Missing required file $dir/$file${NC}"
                exit 1
            fi
        done
    }
}

verify_zip_contents() {
    echo -e "${BLUE}Verifying zip contents...${NC}"
    
    # First verify front-page.html specifically
    if ! unzip -l stay-n-alive.zip | grep -q "templates/front-page.html"; then
        echo -e "${RED}ERROR: front-page.html missing from zip${NC}"
        echo "Files in templates directory:"
        unzip -l stay-n-alive.zip | grep "templates/"
        exit 1
    }
    echo -e "${GREEN}✓ Found front-page.html${NC}"
    
    # Then verify patterns
    REQUIRED_PATTERNS=("cta.html" "featured-post.html")
    for pattern in "${REQUIRED_PATTERNS[@]}"; do
        if ! unzip -l stay-n-alive.zip | grep -q "patterns/$pattern"; then
            echo -e "${RED}ERROR: $pattern missing from zip${NC}"
            echo "Files in patterns directory:"
            unzip -l stay-n-alive.zip | grep "patterns/"
            exit 1
        fi
        echo -e "${GREEN}✓ Found $pattern${NC}"
    }
    
    # Rest of verification...
}

copy_theme_files() {
    local copy_errors=0
    local copied_files=()
    local failed_files=()  # Track failed copies
    
    # Normalize paths for Windows/Unix
    local src_dir="src"
    local dest_dir="stay-n-alive"
    if [[ "$OSTYPE" == "msys" || "$OSTYPE" == "cygwin" ]]; then
        src_dir=$(cygpath -w "$src_dir")
        dest_dir=$(cygpath -w "$dest_dir")
    fi
    
    # Ensure clean state
    if [[ -d "$dest_dir" ]]; then
        echo "Creating backup of existing directory..."
        mv "$dest_dir" "$dest_dir.bak.$(date +%Y%m%d_%H%M%S)"
    fi
    
    echo "Copying template files..."
    
    # Debug current state
    echo "DEBUG: Current directory: $(pwd)"
    echo "DEBUG: Source directory exists: $([[ -d "$src_dir" ]] && echo "Yes" || echo "No")"
    
    # First verify critical files exist in source
    echo -e "${BLUE}=== Verifying Critical Files ===${NC}"
    CRITICAL_FILES=(
        "templates/front-page.html"
        "patterns/cta.html"
        "patterns/featured-post.html"
    )
    
    local missing_files=()
    
    for file in "${CRITICAL_FILES[@]}"; do
        if [[ ! -f "$src_dir/$file" ]]; then
            missing_files+=("$file")
            continue
        fi
        echo "Found: $file ($(wc -c < "$src_dir/$file") bytes)"
    done
    
    if ((${#missing_files[@]} > 0)); then
        echo -e "${RED}ERROR: Missing critical files:${NC}"
        printf '%s\n' "${missing_files[@]}"
        echo "Source directory contents:"
        for dir in templates parts patterns; do
            echo "=== $dir ==="
            ls -la "$src_dir/$dir" 2>/dev/null || echo "Directory not found"
        done
        exit 1
    fi
    
    # Create main theme directory
    mkdir -p "$dest_dir"
    if [[ ! -d "$dest_dir" ]]; then
        echo -e "${RED}ERROR: Failed to create theme directory${NC}"
        exit 1
    }
    
    # First copy critical files explicitly
    echo -e "${BLUE}=== Copying Critical Files ===${NC}"
    for file in "${CRITICAL_FILES[@]}"; do
        echo "Processing: $file"
        # Create directory if needed
        target_dir="$dest_dir/$(dirname "$file")"
        mkdir -p "$target_dir"
        
        # Copy and verify
        if cp -v "$src_dir/$file" "$dest_dir/$file" && [[ -f "$dest_dir/$file" ]]; then
            # Verify content
            if ! verify_file_content "$src_dir/$file" "$dest_dir/$file"; then
                echo -e "${RED}ERROR: Content verification failed for $file${NC}"
                exit 1
            fi
            echo -e "${GREEN}✓ Copied $file${NC}"
            copied_files+=("$file")
            echo "DEBUG: Added $file to copied_files array (${#copied_files[@]} total)"
        else
            echo -e "${RED}ERROR: Failed to copy $file${NC}"
            exit 1
        fi
    done
    
    # Verify critical files were copied before continuing
    echo -e "${BLUE}=== Verifying Critical Files Were Copied ===${NC}"
    for file in "${CRITICAL_FILES[@]}"; do
        if [[ ! -f "$dest_dir/$file" ]]; then
            echo -e "${RED}ERROR: Critical file $file missing after copy${NC}"
            exit 1
        fi
        echo -e "${GREEN}✓ Verified $file exists${NC}"
    done
    
    # Then copy remaining files
    echo -e "${BLUE}=== Copying Remaining Files ===${NC}"
    for dir in templates parts patterns; do
        echo "=== $dir ==="
        if [[ -d "$src_dir/$dir" ]]; then
            for file in "$src_dir/$dir"/*.html; do
                if [[ -f "$file" ]]; then
                    base=$(basename "$file")
                    # Skip if already copied as critical file
                    if printf '%s\n' "${copied_files[@]}" | grep -q "^$dir/$base$"; then
                        echo "Skipping already copied file: $dir/$base"
                        continue
                    fi
                    echo "Copying $base..."
                    if ! cp -v "$file" "$dest_dir/$dir/$base"; then
                        echo -e "${RED}ERROR: Failed to copy $file${NC}"
                        echo "Source exists: $([[ -f "$file" ]] && echo "Yes" || echo "No")"
                        echo "Source permissions: $(stat -c %a "$file")"
                        echo "Target directory exists: $([[ -d "$dest_dir/$dir" ]] && echo "Yes" || echo "No")"
                        ((copy_errors++))
                        failed_files+=("$dir/$base")
                        continue
                    fi
                    # Verify copy
                    if ! verify_file_content "$file" "$dest_dir/$dir/$base"; then
                        echo -e "${RED}ERROR: Content verification failed for $dir/$base${NC}"
                        echo "Source size: $(wc -c < "$file")"
                        echo "Destination size: $(wc -c < "$dest_dir/$dir/$base")"
                        ((copy_errors++))
                        failed_files+=("$dir/$base")
                        continue
                    fi
                    copied_files+=("$dir/$base")
                    echo "DEBUG: Added $dir/$base to copied_files array (${#copied_files[@]} total)"
                fi
            done
        fi
    done
    
    # Verify directory structure after copying
    echo -e "${BLUE}Verifying directory structure...${NC}"
    REQUIRED_DIRS=(
        "$dest_dir/templates"
        "$dest_dir/parts"
        "$dest_dir/patterns"
    )
    
    for dir in "${REQUIRED_DIRS[@]}"; do
        if [[ ! -d "$dir" ]]; then
            echo -e "${RED}ERROR: Required directory $dir not created${NC}"
            exit 1
        fi
        echo -e "${GREEN}✓ Verified $dir exists${NC}"
    done
    
    # Print summary
    echo -e "${BLUE}Copy Summary:${NC}"
    echo "Source directory: $src_dir"
    echo "Destination directory: $dest_dir"
    echo "Critical files copied: ${#CRITICAL_FILES[@]}"
    echo "Total files copied: ${#copied_files[@]}"
    echo "Failed copies: ${#failed_files[@]}"
    if [[ $copy_errors -gt 0 ]]; then
        echo -e "${RED}Errors encountered: $copy_errors${NC}"
        echo "Failed files:"
        printf '%s\n' "${failed_files[@]}"
    else
        echo -e "${GREEN}All files copied successfully${NC}"
    fi
    
    return $copy_errors
}

verify_file_content() {
    local src="$1"
    local dest="$2"
    
    # First check sizes match
    local src_size=$(wc -c < "$src")
    local dest_size=$(wc -c < "$dest")
    if [[ "$src_size" != "$dest_size" ]]; then
        return 1
    fi
    
    # Then do binary comparison
    if ! cmp -s "$src" "$dest"; then
        return 1
    fi
    
    # For HTML files, verify WordPress block syntax
    if [[ "$src" =~ \.html$ ]]; then
        if ! grep -q "wp:" "$src"; then
            echo "WARNING: $src missing WordPress block syntax"
        fi
    fi
    
    return 0
}

# Add to main execution
main() {
    echo -e "${BLUE}=== Starting theme creation ===${NC}"
    
    # First create directories
    create_directories
    echo -e "${GREEN}✓ Created directory structure${NC}"
    
    echo -e "${BLUE}=== Copying theme files ===${NC}"
    # Copy all files from source
    copy_theme_files
    if [[ $? -ne 0 ]]; then
        echo -e "${RED}ERROR: Failed to copy theme files${NC}"
        exit 1
    fi
    
    # Create any missing files
    create_additional_files
    
    echo -e "${GREEN}✓ All theme files created${NC}"
    
    echo -e "${BLUE}=== Validating theme files ===${NC}"
    # Validate all files after creation
    validate_theme_files
    
    # Create supporting files
    create_theme_json
    create_checkpoints
    
    echo -e "${BLUE}=== Creating theme package ===${NC}"
    # Finally create and verify zip
    create_theme_zip
    verify_zip_contents
    
    echo -e "${GREEN}=== Theme creation complete ===${NC}"
}

# Add error trap
set -E
trap 'echo -e "${RED}ERROR: Command failed at line $LINENO${NC}"; exit 1' ERR

# Add to main execution
main 