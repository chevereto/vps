#!/usr/bin/env bash

set -e

# scripts/00-update.sh
cat <<EOF
Updating system packages...
This could take some minutes

EOF

update() {
    DEBIAN_FRONTEND=noninteractive apt-get update -y -qq >/dev/null
    apt-get upgrade -qq -y >/dev/null
}
update
apt-get install -qq -y ca-certificates apt-transport-https software-properties-common
add-apt-repository -y ppa:ondrej/php
add-apt-repository -y ppa:ondrej/apache2
apt-get install -qq -y apache2 libapache2-mod-php8.1
apt-get install -qq -y mysql-server
apt-get install -qq -y php8.1
apt-get install -qq -y php8.1-{bcmath,common,cli,curl,fileinfo,gd,imagick,intl,mbstring,mysql,opcache,pdo,pdo-mysql,xml,xmlrpc,zip}
apt-get install -qq -y python3-certbot-apache unzip

# composer
if ! command -v composer &>/dev/null; then
    echo "Installing composer"
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

# safe update
update

echo "[OK] Stack ready for Chevereto!"
