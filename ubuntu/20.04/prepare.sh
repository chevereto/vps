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

# safe update
update

echo "[OK] Stack ready for Chevereto!"
