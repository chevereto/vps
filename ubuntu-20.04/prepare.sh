#!/usr/bin/env bash

set -e

# scripts/00-update.sh
cat <<EOF
Updating system packages. This could take some minutes and it may reboot the system."
EOF
DEBIAN_FRONTEND=noninteractive apt-get update -qq >/dev/null
apt-get install -qq -y ca-certificates apt-transport-https software-properties-common
add-apt-repository -y ppa:ondrej/php
apt-get install -qq -y apache2 libapache2-mod-php8.1
apt-get install -qq -y mysql-server
apt-get install -qq -y php8.1
apt-get install -y php8.1-{bcmath,common,cli,curl,fileinfo,gd,imagick,intl,mbstring,mysql,opcache,pdo,pdo-mysql,xml,xmlrpc,zip}
apt-get install -y python3-certbot-apache software-properties-common unzip

# safe update
DEBIAN_FRONTEND=noninteractive apt-get update -qq >/dev/null
apt-get upgrade -qq -y >/dev/null
