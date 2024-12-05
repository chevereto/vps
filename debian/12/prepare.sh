#!/usr/bin/env bash

set -e

if [ "$(id -u)" -ne 0 ]; then
    if ! command -v sudo &>/dev/null; then
    echo "sudo package is not installed. Please install sudo first."
    exit 1
fi
    echo "Running with sudo privileges..."
    SUDO='sudo'
else
    SUDO=''
fi

cat <<EOF
Updating system packages...
This could take some minutes
EOF

install_php_repo() {
    if ! command -v curl &>/dev/null; then
      echo "curl is not installed. Installing curl..."
      $SUDO apt-get update -qq && $SUDO apt-get install -qq -y curl
    fi
    if ! command -v lsb_release &>/dev/null; then
      echo "installing lsb_release"
      $SUDO apt-get update -qq && $SUDO apt-get install -qq -y lsb-release
    fi
    $SUDO curl -sSLo /usr/share/keyrings/deb.sury.org-php.gpg https://packages.sury.org/php/apt.gpg
    $SUDO sh -c 'echo "deb [signed-by=/usr/share/keyrings/deb.sury.org-php.gpg] https://packages.sury.org/php/ $(lsb_release -sc) main" > /etc/apt/sources.list.d/php.list'
}

if ! dpkg -l | grep -q apt-transport-https; then
    echo "apt-transport-https is not installed"
    $SUDO apt-get update -qq && $SUDO apt-get install -qq -y apt-transport-https
    install_php_repo
else
    echo "apt-transport-https is already installed"
    install_php_repo
fi

update() {
    DEBIAN_FRONTEND=noninteractive $SUDO apt-get update -y -qq >/dev/null
    $SUDO apt-get upgrade -qq -y >/dev/null
}

update
read -p "Do you want to install nginx or apache? (nginx/apache): " webserver_choice
if [ "$webserver_choice" = "apache" ]; then
  $SUDO apt-get install -qq -y apache2 libapache2-mod-php8.3 certbot python3-certbot-apache
else
  $SUDO apt-get install -qq -y nginx-full php8.3-fpm certbot python3-certbot-nginx
fi

$SUDO apt-get install -qq -y ca-certificates software-properties-common unzip ffmpeg cron
$SUDO apt-get install -qq -y mariadb-server
$SUDO apt-get install -qq -y php8.3 php8.3-{bcmath,common,cli,curl,fileinfo,gd,imagick,intl,mbstring,mysql,opcache,pdo,pdo-mysql,xml,xmlrpc,zip}

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
    $SUDO chmod +x /usr/local/bin/composer
else
    composer selfupdate
fi

# safe update
update

echo "[OK] Stack ready for Chevereto!"