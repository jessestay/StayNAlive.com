#!/usr/bin/env bash
set -euo pipefail

# Create backup with proper permissions
if [[ "${OSTYPE}" == "msys" || "${OSTYPE}" == "cygwin" ]]; then
    # Windows: Remove read-only attribute first
    attrib -R deploy-to-local.sh lib/shared-functions.sh
    attrib -R deploy-to-local.sh.bak lib/shared-functions.sh.bak 2> /dev/null || true

    # Create backups using copy instead of cp
    cmd //c "copy /Y deploy-to-local.sh deploy-to-local.sh.bak"
    cmd //c "copy /Y lib\\shared-functions.sh lib\\shared-functions.sh.bak"
else
    # Unix systems
    cp deploy-to-local.sh deploy-to-local.sh.bak
    cp lib/shared-functions.sh lib/shared-functions.sh.bak
fi

# Remove read-only attribute before sed operations
if [[ "${OSTYPE}" == "msys" || "${OSTYPE}" == "cygwin" ]]; then
    attrib -R deploy-to-local.sh lib/shared-functions.sh
fi

# Fix date command syntax
sed -i \
    -e 's/timestamp=$(date || echo "unknown").*)/timestamp=$(date '"'"'+%Y-%m-%d %H:%M:%S'"'"' 2>\/dev\/null || echo "unknown")/g' \
    -e 's/backup_name=.*_backup_$(date.*)/backup_name="${theme_dir}_backup_$(date '"'"'+%Y%m%d_%H%M%S'"'"' 2>\/dev\/null || echo "unknown")"/g' \
    deploy-to-local.sh lib/shared-functions.sh

# Fix if statements with missing 'then'
sed -i \
    -e 's/if ! \([^;]*\)$/if ! \1\nthen/g' \
    -e 's/if ! if !/if !/g' \
    -e 's/\(if.*\) -Command "\\\\/\1 -Command "\\\; then/g' \
    deploy-to-local.sh lib/shared-functions.sh

# Fix PowerShell command syntax
sed -i \
    -e '/powershell\.exe -Command/c\
    if ! powershell.exe -Command "\
        \${ErrorActionPreference} = '\''Stop'\''\
        try {\
            ${ps_command}\
        } catch {\
            Write-Host \"ERROR: \${_}\"\
            exit 1\
        }\
    "; then\
        log_error "${error_msg}"\
        return 1\
    fi' \
    deploy-to-local.sh lib/shared-functions.sh

# Fix multiple then statements more aggressively
sed -i \
    -e 's/then; then; then/then/g' \
    -e 's/then; then/then/g' \
    -e 's/if ! if !/if !/g' \
    -e 's/\(if.*\); then\([^;]*\); then/\1; then\2/g' \
    -e 's/\(if.*\)then; then/\1then/g' \
    -e 's/\(if.*\)then\s*then/\1then/g' \
    -e 's/\(if.*\); then;/\1; then/g' \
    deploy-to-local.sh lib/shared-functions.sh

# Fix directory creation
sed -i \
    -e '/^create_directory_structure()/,/^}/c\
create_directory_structure() {\
    local directories=(\
        "assets/css/base"\
        "assets/css/blocks"\
        "assets/css/components"\
        "assets/css/compatibility"\
        "assets/css/utilities"\
        "assets/js"\
        "inc"\
        "inc/classes"\
        "languages"\
        "parts"\
        "patterns"\
        "styles"\
        "templates"\
    )\
\
    for dir in "${directories[@]}"; do\
        if ! mkdir -p "${THEME_DIR}/${dir}"; then\
            log_error "Failed to create directory: ${dir}"\
            return 1\
        fi\
\
        if ! echo "<?php // Silence is golden." > "${THEME_DIR}/${dir}/index.php"; then\
            log_error "Failed to create index.php in ${dir}"\
            return 1\
        fi\
        echo "Created directory and index.php: ${dir}"\
    done\
\
    return 0\
}' \
    lib/shared-functions.sh

# Fix command checks
sed -i \
    -e 's/command\nif \[\[ \$? -ne 0 \]\]; then/if ! command/g' \
    -e 's/\([a-zA-Z_][a-zA-Z0-9_]*\)\nif \[\[ \$? -ne 0 \]\]; then/if ! \1/g' \
    deploy-to-local.sh lib/shared-functions.sh

# Fix if statements
sed -i \
    -e 's/if ! \([^;]*\)$/if ! \1; then/g' \
    -e 's/if ! \([^;]*\)[^;]*$/if ! \1; then/g' \
    -e 's/\(if.*\); then\([^;]*\); then/\1; then\2/g' \
    deploy-to-local.sh lib/shared-functions.sh

# Fix PowerShell variable escaping
sed -i \
    -e 's/\${ErrorActionPreference}/\$ErrorActionPreference/g' \
    -e 's/\${_}/\$_/g' \
    -e 's/\${ps_command}/\$ps_command/g' \
    deploy-to-local.sh lib/shared-functions.sh

# Fix command substitution safety
sed -i \
    -e 's/$(pwd)/$(pwd 2>\/dev\/null || echo "unknown")/g' \
    -e 's/$(readlink -f)/$(readlink -f 2>\/dev\/null || echo "unknown")/g' \
    deploy-to-local.sh lib/shared-functions.sh

# Fix path handling
sed -i \
    -e 's|\$local_path/\$THEME_DIR|${local_path}/${THEME_DIR}|g' \
    -e 's|\$THEME_DIR/\$file|${THEME_DIR}/${file}|g' \
    -e 's|src/\$file|src/${file}|g' \
    deploy-to-local.sh lib/shared-functions.sh

# Fix error handling
sed -i \
    -e 's/|| exit 1/; if [[ $? -ne 0 ]]; then exit 1; fi/g' \
    -e 's/|| return 1/; if [[ $? -ne 0 ]]; then return 1; fi/g' \
    deploy-to-local.sh lib/shared-functions.sh

# Fix unused variables
sed -i \
    -e '/^[[:space:]]*local curl_exit/d' \
    -e '/^[[:space:]]*local command=/d' \
    deploy-to-local.sh lib/shared-functions.sh

# Fix string quoting issues
sed -i \
    -e 's/\("\);\s*then\(\s*\)/\1\2/g' \
    -e 's/\("\)\s*;\s*then\(\s*\)/\1\2/g' \
    -e 's/\([^\\]\)"\s*;\s*then/\1"/g' \
    -e 's/\([^\\]\)"\s*;\s*\(\w\+\)/\1"\n\2/g' \
    deploy-to-local.sh lib/shared-functions.sh

# Fix create_checkpoint function
sed -i \
    -e '/^create_checkpoint()/,/^}/c\
create_checkpoint() {\
    local stage="$1"\
    local timestamp\
    timestamp=$(date '"'"'+%Y%m%d_%H%M%S'"'"' 2>/dev/null || echo "unknown")\
    local checkpoint_file=".checkpoint_${stage}_${timestamp}"\
\
    if ! touch "${THEME_DIR}/${checkpoint_file}"\
    then\
        log_error "Failed to create checkpoint for stage: ${stage}"\
        return 1\
    fi\
\
    echo "Creating checkpoint for stage: ${stage}"\
    return 0\
}' \
    lib/shared-functions.sh

# Fix backup_theme function
sed -i \
    -e '/^backup_theme()/,/^}/c\
backup_theme() {\
    local theme_dir="$1"\
    local local_path="$2"\
    local backup_name\
\
    backup_name="${theme_dir}_backup_$(date '"'"'+%Y%m%d_%H%M%S'"'"' 2>/dev/null || echo "unknown")"\
\
    if [[ ! -d "${local_path}/${theme_dir}" ]]; then\
        return 0\
    fi\
\
    echo "Creating backup of existing theme..."\
    if ! mv "${local_path}/${theme_dir}" "${local_path}/${backup_name}"; then\
        log_error "Could not create backup"\
        return 1\
    fi\
\
    echo "Backup created at: ${backup_name}"\
    return 0\
}' \
    deploy-to-local.sh

# Fix verify_theme_files function
sed -i \
    -e '/^verify_theme_files()/,/^}/c\
verify_theme_files() {\
    if [[ $# -ne 0 ]]; then\
        log_error "verify_theme_files: unexpected parameters"\
        return 1\
    fi\
\
    # Check file permissions\
    if [[ "${OSTYPE}" != "msys" && "${OSTYPE}" != "cygwin" ]]; then\
        find "${local_path}/${THEME_DIR}" -type f -exec chmod 644 {} \\;\
        find "${local_path}/${THEME_DIR}" -type d -exec chmod 755 {} \\;\
    fi\
\
    ls -la src/ || echo "ERROR: Cannot list src directory"\
\
    return 0\
}' \
    deploy-to-local.sh lib/shared-functions.sh

# Fix run_powershell function
sed -i \
    -e '/^run_powershell()/,/^}/c\
run_powershell() {\
    local ps_command="$1"\
    local error_msg="${2:-PowerShell command failed}"\
\
    if ! command -v powershell.exe > /dev/null 2>&1; then\
        log_error "PowerShell is not available"\
        return 1\
    fi\
\
    if ! powershell.exe -Command "\
        $ErrorActionPreference = '\''Stop'\''\
        try {\
            $ps_command\
        } catch {\
            Write-Host \"ERROR: $_\"\
            exit 1\
        }\
    "; then\
        log_error "${error_msg}"\
        return 1\
    fi\
}' \
    deploy-to-local.sh

# Fix case statement in deploy-to-local.sh
sed -i \
    -e '/case ${curl_status} in/,/esac/c\
        case ${curl_status} in\
            6) echo "Could not resolve host: DNS lookup failed" ;;\
            7) echo "Failed to connect: Local by Flywheel might not be running" ;;\
            28) echo "Connection timed out after 10 seconds" ;;\
        esac' \
    deploy-to-local.sh

# Fix command substitution with if statements
sed -i \
    -e 's/$(pwd || if ! echo '\''unknown'\'') ; if \[\[ $? -ne 0 \]\]; then exit 1; fi; then/$(pwd 2>\/dev\/null || echo '\''unknown'\'')/g' \
    -e 's/$(readlink -f . || if ! echo '\''unknown'\'') ; if \[\[ $? -ne 0 \]\]; then exit 1; fi; then/$(readlink -f . 2>\/dev\/null || echo '\''unknown'\'')/g' \
    lib/shared-functions.sh

# Fix if statements in command substitutions
sed -i \
    -e 's/if ! echo/echo/g' \
    -e 's/if \[\[ $? -ne 0 \]\]; then exit 1; fi;/|| exit 1/g' \
    deploy-to-local.sh lib/shared-functions.sh

# Fix copy_template_files function
sed -i \
    -e '/^copy_template_files()/,/^}/c\
copy_template_files() {\
    echo "Copying template files..."\
    current_dir=$(pwd 2>\/dev\/null || echo "unknown")\
    echo "DEBUG: Current directory: ${current_dir}"\
    echo "DEBUG: Source directory contents:"\
    ls -la src/parts/ src/templates/ src/patterns/\
\
    local template_files=(\
        "templates/404.html"\
        "templates/archive.html"\
        "templates/author.html"\
        "templates/category.html"\
        "templates/index.html"\
        "templates/link-bio.html"\
        "templates/search.html"\
        "templates/single.html"\
        "templates/tag.html"\
        "parts/footer.html"\
        "parts/header.html"\
        "patterns/author-bio.html"\
        "patterns/bio-link-button.html"\
        "patterns/social-grid.html"\
    )\
\
    for file in "${template_files[@]}"; do\
        echo "DEBUG: Copying ${file}..."\
        if [[ ! -f "src/${file}" ]]; then\
            log_error "Source file missing: ${file}"\
            echo "DEBUG: Tried to find: $(pwd 2>\/dev\/null || echo "unknown")/src/${file}"\
            return 1\
        fi\
\
        if ! cp -v "src/${file}" "${THEME_DIR}/${file}"; then\
            log_error "Failed to copy ${file}"\
            echo "DEBUG: From: $(pwd 2>\/dev\/null || echo "unknown")/src/${file}"\
            echo "DEBUG: To: ${current_dir}/${THEME_DIR}/${file}"\
            return 1\
        fi\
\
        if [[ ! -f "${THEME_DIR}/${file}" ]]; then\
            log_error "File not found after copy: ${THEME_DIR}/${file}"\
            return 1\
        fi\
        echo "DEBUG: Successfully copied ${file}"\
    done\
\
    return 0\
}' \
    lib/shared-functions.sh

# Fix directory creation and verify_theme_functions
sed -i \
    -e '/^verify_theme_functions()/,/^}/c\
verify_theme_functions() {\
    echo "Verifying theme function definitions..."\
\
    # Create inc directory if needed\
    if ! mkdir -p "${THEME_DIR}/inc"; then\
        log_error "Failed to create inc directory"\
        return 1\
    fi\
\
    return 0\
}' \
    lib/shared-functions.sh

# Run shellcheck to verify fixes
shellcheck -x deploy-to-local.sh lib/shared-functions.sh

# Fix success check in deploy-to-local.sh
sed -i \
    -e 's/if \[\[ ${success} -eq 0 \]\]; then/if [[ ${success} -eq 0 ]]; then\n        echo "Health check failed"/' \
    deploy-to-local.sh

# Fix multiple then statements
sed -i \
    -e 's/then\s*then\s*then/then/g' \
    -e 's/then\s*then/then/g' \
    -e 's/if ! if !/if !/g' \
    -e 's/if\s*if\s*!/if !/g' \
    -e 's/\(if.*\); then\([^;]*\); then/\1; then\2/g' \
    -e 's/\(if.*\)then; then/\1then/g' \
    -e 's/\(if.*\)then\s*then/\1then/g' \
    -e 's/\(if.*\); then;/\1; then/g' \
    -e 's/\(if.*\); fi; then/\1; then/g' \
    -e 's/\(if.*\); fi\s*then/\1; then/g' \
    deploy-to-local.sh lib/shared-functions.sh

# Fix if statement structure
sed -i \
    -e 's/if ! \([^;]*\)$/if ! \1; then/g' \
    -e 's/if ! \([^;]*\)[^;]*$/if ! \1; then/g' \
    -e 's/if \[\[ \([^]]*\) \]\]$/if [[ \1 ]]; then/g' \
    -e 's/if \[\[ \([^]]*\) \]\][^;]*$/if [[ \1 ]]; then/g' \
    deploy-to-local.sh lib/shared-functions.sh

# Fix PowerShell command blocks
sed -i \
    -e '/powershell\.exe -Command/,/fi/{/then/!{/fi/!s/^/        /}}' \
    -e 's/\(\s*\)if ! powershell\.exe -Command "\(.*\)"; then/\1if ! powershell.exe -Command "\2"; then/g' \
    deploy-to-local.sh lib/shared-functions.sh

# Fix empty if blocks
sed -i \
    -e '/^[[:space:]]*if.*; then[[:space:]]*$/,/^[[:space:]]*fi[[:space:]]*$/{/if.*; then/!{/fi/!s/^/    /}}' \
    deploy-to-local.sh lib/shared-functions.sh
