#!/usr/bin/env bash
#
# PHP Installation
# --------------
# Installs PHP, common extensions, and Composer
#
# Author: Atelier Team
# License: MIT

set -euo pipefail

SCRIPT_DIR="$(dirname "$(realpath "$0")")"
source "${SCRIPT_DIR}/../../lib/utils.sh"

log_info "[php] Installing PHP and related tools..."

# Check if PHP is already installed
if ! command -v php &> /dev/null; then
    # Add PHP repository
    log_info "[php] Adding PHP repository..."
    sudo add-apt-repository -y ppa:ondrej/php
    
    # Update package lists
    sudo apt-get update
    
    # Install PHP and common extensions
    log_info "[php] Installing PHP and common extensions..."
    sudo apt-get install -y \
        php8.2 \
        php8.2-cli \
        php8.2-fpm \
        php8.2-common \
        php8.2-mysql \
        php8.2-zip \
        php8.2-gd \
        php8.2-mbstring \
        php8.2-curl \
        php8.2-xml \
        php8.2-bcmath \
        php8.2-json \
        php8.2-intl \
        php8.2-readline \
        php8.2-ldap \
        php8.2-sqlite3 \
        php8.2-tokenizer \
        php-xdebug

    # Install Composer
    log_info "[php] Installing Composer..."
    EXPECTED_CHECKSUM="$(php -r 'copy("https://composer.github.io/installer.sig", "php://stdout");')"
    php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');"
    ACTUAL_CHECKSUM="$(php -r "echo hash_file('sha384', 'composer-setup.php');")"

    if [ "$EXPECTED_CHECKSUM" != "$ACTUAL_CHECKSUM" ]; then
        log_error "[php] Composer installer checksum verification failed."
        rm composer-setup.php
        exit 1
    fi

    php composer-setup.php --quiet
    rm composer-setup.php
    sudo mv composer.phar /usr/local/bin/composer
    
    # Create PHP configuration directory if it doesn't exist
    sudo mkdir -p /etc/php/8.2/cli/conf.d

    # Configure PHP
    log_info "[php] Configuring PHP..."
    echo "
; Custom PHP configuration
memory_limit = 256M
max_execution_time = 120
upload_max_filesize = 64M
post_max_size = 64M
max_input_vars = 3000
date.timezone = UTC
" | sudo tee /etc/php/8.2/cli/conf.d/99-custom.ini

    # Configure Xdebug
    log_info "[php] Configuring Xdebug..."
    echo "
zend_extension=xdebug.so
xdebug.mode=develop,debug
xdebug.start_with_request=yes
xdebug.client_host=127.0.0.1
xdebug.client_port=9003
" | sudo tee /etc/php/8.2/mods-available/xdebug.ini

    # Create global Composer configuration directory
    mkdir -p "$HOME/.composer"

    # Configure Composer
    log_info "[php] Configuring Composer..."
    composer config -g repos.packagist composer https://packagist.org
    composer config -g github-oauth.github.com "${GITHUB_TOKEN:-}"

    log_success "[php] PHP and Composer installed successfully!"
    
    # Display help information
    log_info "[php] Quick start guide:"
    echo "
    PHP:
    - Check version: php -v
    - Start built-in server: php -S localhost:8000
    - Check configuration: php -i
    
    Composer:
    - Create new project: composer create-project
    - Install dependencies: composer install
    - Update dependencies: composer update
    - Add package: composer require vendor/package
    
    Common Extensions:
    - All major extensions are installed and configured
    - Xdebug is installed for debugging
    - Check loaded extensions: php -m
    
    Configuration:
    - PHP config location: /etc/php/8.2/cli/conf.d/
    - Composer config: ~/.composer/config.json
    "
else
    log_warn "[php] PHP is already installed."
fi

# Verify installations
log_info "[php] Verifying installations..."
echo "PHP version:"
php -v
echo -e "\nComposer version:"
composer --version