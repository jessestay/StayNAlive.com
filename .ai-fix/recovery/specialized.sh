#!/bin/bash

# WordPress-specific recovery
recover_wordpress() {
    local error_msg="$1"
    
    # Fix common WordPress issues
    wp package install wp-cli/doctor-command
    wp doctor check --all
    wp doctor fix --all
    
    # Fix permissions
    find . -type f -exec chmod 644 {} \;
    find . -type d -exec chmod 755 {} \;
    
    # Fix database issues
    wp db repair
    wp db optimize
}

# Node.js-specific recovery
recover_nodejs() {
    local error_msg="$1"
    
    # Fix common Node.js issues
    rm -rf node_modules/.cache
    npm rebuild
    npm dedupe
    
    # Update npm itself if needed
    npm install -g npm@latest
    
    # Clear various caches
    npm cache clean --force
    yarn cache clean 2>/dev/null || true
}

# PHP-specific recovery
recover_php() {
    local error_msg="$1"
    
    # Fix common PHP issues
    composer dump-autoload
    composer clear-cache
    
    # Fix PHP configuration
    if [[ -f "php.ini" ]]; then
        sed -i 's/max_execution_time = .*/max_execution_time = 300/' php.ini
        sed -i 's/memory_limit = .*/memory_limit = 512M/' php.ini
        sed -i 's/post_max_size = .*/post_max_size = 64M/' php.ini
    fi
}

# Git-specific recovery
recover_git() {
    local error_msg="$1"
    
    # Fix common Git issues
    git gc --prune=now
    git fsck --full
    
    # Fix Git hooks
    if [[ -d ".git/hooks" ]]; then
        find .git/hooks -type f -exec chmod +x {} \;
    fi
    
    # Fix Git LFS issues
    if command -v git-lfs >/dev/null 2>&1; then
        git lfs prune
        git lfs fetch --all
    fi
}

# Build tool recovery
recover_build_tools() {
    local error_msg="$1"
    
    # Fix webpack issues
    if [[ -f "webpack.config.js" ]]; then
        rm -rf .webpack-cache
        npm rebuild node-sass
        npm rebuild webpack
    fi
    
    # Fix Babel issues
    if [[ -f ".babelrc" || -f "babel.config.js" ]]; then
        rm -rf node_modules/.cache/babel-loader
        npm install --save-dev @babel/core @babel/preset-env
    fi
    
    # Fix PostCSS issues
    if [[ -f "postcss.config.js" ]]; then
        npm install --save-dev postcss postcss-cli autoprefixer
    fi
}

# Docker recovery
recover_docker() {
    local error_msg="$1"
    
    # Clean up Docker resources
    docker system prune -f
    docker volume prune -f
    
    # Rebuild containers
    if [[ -f "docker-compose.yml" ]]; then
        docker-compose down
        docker-compose build --no-cache
        docker-compose up -d
    fi
} 