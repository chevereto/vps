#!/usr/bin/env bash

set -e

# scripts/00-update.sh
cat <<EOF
Updating system packages...
This could take some minutes

EOF

# stop prompts
sed -i 's/#$nrconf{restart} = '"'"'i'"'"';/$nrconf{restart} = '"'"'a'"'"';/g' /etc/needrestart/needrestart.conf || true

update() {
    DEBIAN_FRONTEND=noninteractive apt-get update -y -qq >/dev/null
    apt-get upgrade -qq -y >/dev/null
}
update
apt-get install -qq -y ca-certificates apt-transport-https software-properties-common
apt-get install -qq -y mysql-server
apt-get install -qq -y ffmpeg
apt-get install -qq -y python3-certbot-apache unzip
add-apt-repository -y ppa:ondrej/php
add-apt-repository -y ppa:ondrej/apache2
apt-get install -qq -y apache2 libapache2-mod-php8.3
apt-get install -qq -y php8.3
apt-get install -qq -y php8.3-bcmath
apt-get install -qq -y php8.3-common
apt-get install -qq -y php8.3-cli
apt-get install -qq -y php8.3-curl
apt-get install -qq -y php8.3-fileinfo
apt-get install -qq -y php8.3-gd
apt-get install -qq -y php8.3-imagick
apt-get install -qq -y php8.3-intl
apt-get install -qq -y php8.3-mbstring
apt-get install -qq -y php8.3-mysql
apt-get install -qq -y php8.3-opcache
apt-get install -qq -y php8.3-pdo
apt-get install -qq -y php8.3-pdo-mysql
apt-get install -qq -y php8.3-xml
apt-get install -qq -y php8.3-xmlrpc
apt-get install -qq -y php8.3-zip

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
