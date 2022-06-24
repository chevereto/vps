#!/usr/bin/env bash

set -e

# init.sh (start)
PROJECT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" &>/dev/null && pwd)"
WORKING_DIR="/var/www/html"

# Tags
CHEVERETO_SOFTWARE="chevereto"
CHEVERETO_VERSION="4"
CHEVERETO_TAG=${CHEVERETO_TAG:-${CHEVERETO_VERSION}}
CHEVERETO_PACKAGE=$CHEVERETO_TAG"-lite"
CHEVERETO_API_DOWNLOAD="https://chevereto.com/api/download/"
CHEVERETO_LABEL="Chevereto V$CHEVERETO_VERSION"

# Header
cat <<EOM
      __                        __
 ____/ /  ___ _  _____ _______ / /____
/ __/ _ \/ -_) |/ / -_) __/ -_) __/ _ \\
\__/_//_/\__/|___/\__/_/  \__/\__/\___/

EOM

# Ask license
echo -n "$CHEVERETO_LABEL License (hidden):"
read -s CHEVERETO_LICENSE
echo ""

# Download
rm -rf ${CHEVERETO_SOFTWARE}*.zip
curl -f -SOJL \
    -H "License: $CHEVERETO_LICENSE" \
    "${CHEVERETO_API_DOWNLOAD}${CHEVERETO_PACKAGE}"

# composer
if ! command -v composer &>/dev/null; then
    COMPOSER_CHECKSUM_VERIFY="$(php -r 'copy("https://composer.github.io/installer.sig", "php://stdout");')"
    php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');"
    COMPOSER_HASH_FILE="$(php -r "echo hash_file('sha384', 'composer-setup.php');")"
    if [ "$COMPOSER_CHECKSUM_VERIFY" != "$COMPOSER_HASH_FILE" ]; then
        echo >&2 'ERROR: Invalid Composer installer checksum'
        rm composer-setup.php
        exit 1
    fi
    php composer-setup.php --install-dir=/usr/local/bin --filename=composer
    rm composer-setup.php
    chmod +x /usr/local/bin/composer
else
    composer selfupdate
fi

# Extract
unzip -oq ${CHEVERETO_SOFTWARE}*.zip -d $WORKING_DIR
rm -rf ${CHEVERETO_SOFTWARE}*.zip

# Composer Install
chown -R www-data: $WORKING_DIR
sudo -u www-data composer install \
    --working-dir=$WORKING_DIR/app \
    --prefer-dist \
    --no-progress \
    --classmap-authoritative \
    --ignore-platform-reqs

# CLI install (database update)
sudo -u www-data $WORKING_DIR/app/bin/legacy -C install

echo "[OK] $CHEVERETO_LABEL provisioned!"
