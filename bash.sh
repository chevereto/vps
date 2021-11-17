#!/usr/bin/env bash

set -e

# init.sh (start)
PROJECT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" &>/dev/null && pwd)"
WORKING_DIR="/var/www/html"
PROJECT_IP=$(hostname -I | awk '{ print $1 }')

# Flags
while getopts ":t:" opt; do
    case $opt in
    t)
        CHEVERETO_TAG=$OPTARG
        echo "Using tag $OPTARG" >&2
        ;;
    \?)
        echo "Invalid option: -$OPTARG" >&2
        exit 1
        ;;
    :)
        echo "Option -$OPTARG requires an argument." >&2
        exit 1
        ;;
    esac
done

# Tags
CHEVERETO_SOFTWARE="chevereto"
CHEVERETO_VERSION="3"
CHEVERETO_TAG=${CHEVERETO_TAG:-${CHEVERETO_VERSION}}
CHEVERETO_PACKAGE=$CHEVERETO_TAG
CHEVERETO_API_DOWNLOAD="https://chevereto.com/api/download/"
CHEVERETO_LABEL="Chevereto V$CHEVERETO_TAG"

# Header
cat <<EOM
      __                        __     
 ____/ /  ___ _  _____ _______ / /____ 
/ __/ _ \/ -_) |/ / -_) __/ -_) __/ _ \ 
\__/_//_/\__/|___/\__/_/  \__/\__/\___/

EOM

# Ask license
echo -n "$CHEVERETO_LABEL License:"
read -s CHEVERETO_LICENSE
echo ""

# Download
curl -f -SOJL \
    -X POST -d "nowrap" \
    -H "License: $CHEVERETO_LICENSE" \
    "${CHEVERETO_API_DOWNLOAD}${CHEVERETO_PACKAGE}"

# scripts/00-update.sh
echo "[UP] Updating packages... This could take some minutes."
DEBIAN_FRONTEND=noninteractive apt-get update -qq >/dev/null
apt-get install -qq -y apache2 libapache2-mod-php
apt-get install -qq -y mysql-server
apt-get install -qq -y php
apt-get install -y php-{common,cli,curl,fileinfo,gd,imagick,intl,json,mbstring,mysql,opcache,pdo,pdo-mysql,xml,xmlrpc,zip}
apt-get install -y python3-certbot-apache software-properties-common unzip

# Extract
rm -rf "${WORKING_DIR}"/*
unzip -oq ${CHEVERETO_SOFTWARE}*.zip -d $WORKING_DIR

# scripts/01-fs.sh
cat >/etc/apache2/sites-available/000-default.conf <<EOM
<VirtualHost *:80>
    <Directory /var/www/html>
        Options Indexes FollowSymLinks
        AllowOverride All
        Require all granted
    </Directory>
    ServerAdmin webmaster@localhost
    DocumentRoot /var/www/html
    ErrorLog \${APACHE_LOG_DIR}/error.log
    CustomLog \${APACHE_LOG_DIR}/access.log combined
</VirtualHost>
EOM
cat >/etc/update-motd.d/99-one-click <<EOM
#!/usr/bin/env bash

myip=\$(hostname -I | awk '{print\$1}')
cat <<EOF
********************************************************************************
      __                        __     
 ____/ /  ___ _  _____ _______ / /____ 
/ __/ _ \/ -_) |/ / -_) __/ -_) __/ _ \ 
\__/_//_/\__/|___/\__/_/  \__/\__/\___/

Welcome to your Chevereto server!

To keep this server secure, the UFW firewall is enabled.
All ports are BLOCKED except 22 (SSH), 80 (HTTP), and 443 (HTTPS).

In a web browser, you can view:
 * The Chevereto website: http://\$myip/

On the server:
 * The default web root is located at /var/www/html
 * The MySQL root password is saved at /root/.mysql_password
 * Certbot is preinstalled, to configure HTTPS run:
   > certbot --apache -d example.com -d www.example.com

IMPORTANT:
 * After connecting to the server for the first time, immediately install
   Chevereto at http://\$myip/
 * Secure your database by running:
   > mysql_secure_installation
 * Setup email delivery at http://\$myip/dashboard/settings/email

For help and more information visit https://chevereto.com

********************************************************************************
To delete this message of the day: rm -rf \$(readlink -f \${0})
EOF
EOM
chmod +x /etc/update-motd.d/99-one-click
cat >/etc/cron.d/chevereto <<EOM
* * * * * www-data php /var/www/html/cli.php -C cron
EOM

# scripts/10-php.sh
cat >/etc/php/7.4/apache2/conf.d/chevereto.ini <<EOM
log_errors = On
upload_max_filesize = 50M
post_max_size = 50M
max_execution_time = 60
memory_limit = 512M
EOM

# files/var/lib/cloud/scripts/per-instance/provision.sh (*)
echo $(date -u) ": System provisioning started." >>/var/log/per-instance.log
MYSQL_ROOT_PASS=$(openssl rand -hex 16)
DEBIAN_SYS_MAINT_MYSQL_PASS=$(openssl rand -hex 16)
CHEVERETO_DB_HOST=localhost
CHEVERETO_DB_PORT=3306
CHEVERETO_DB_NAME=chevereto
CHEVERETO_DB_USER=chevereto
CHEVERETO_DB_PASS=$(openssl rand -hex 16)
cat >/root/.mysql_password <<EOM
MYSQL_ROOT_PASS="${MYSQL_ROOT_PASS}"
EOM
mysql -u root -e "CREATE DATABASE $CHEVERETO_DB_NAME;"
mysql -u root -e "CREATE USER '$CHEVERETO_DB_USER'@'$CHEVERETO_DB_HOST' IDENTIFIED BY '$CHEVERETO_DB_PASS';"
mysql -u root -e "GRANT ALL ON *.* TO '$CHEVERETO_DB_USER'@'$CHEVERETO_DB_HOST';"
mysqladmin -u root -h localhost password $MYSQL_ROOT_PASS
mysql -uroot -p${MYSQL_ROOT_PASS} \
    -e "ALTER USER 'debian-sys-maint'@'localhost' IDENTIFIED BY '$DEBIAN_SYS_MAINT_MYSQL_PASS';"
cat >/etc/mysql/debian.cnf <<EOM
# Automatically generated for Debian scripts. DO NOT TOUCH!
[client]
host     = localhost
user     = debian-sys-maint
password = ${DEBIAN_SYS_MAINT_MYSQL_PASS}
socket   = /var/run/mysqld/mysqld.sock
[mysql_upgrade]
host     = localhost
user     = debian-sys-maint
password = ${DEBIAN_SYS_MAINT_MYSQL_PASS}
socket   = /var/run/mysqld/mysqld.sock
EOM

# Settings
cat >"$WORKING_DIR/app/settings.php" <<EOM
<?php
\$settings['db_host'] = '${CHEVERETO_DB_HOST}';
\$settings['db_port'] = '${CHEVERETO_DB_PORT}';
\$settings['db_name'] = '${CHEVERETO_DB_NAME}';
\$settings['db_user'] = '${CHEVERETO_DB_USER}';
\$settings['db_pass'] = '${CHEVERETO_DB_PASS}';
\$settings['db_table_prefix'] = 'chv_';
\$settings['db_driver'] = 'mysql';
\$settings['db_pdo_attrs'] = [];
\$settings['debug_level'] = 1;
EOM

# scripts/12-apache.sh
chown -R www-data: /var/log/apache2
chown -R www-data: /etc/apache2
chown -R www-data: $WORKING_DIR
a2enmod rewrite

# files/var/lib/cloud/scripts/per-instance/provision.sh (*)
systemctl restart apache2

# common/scripts/14-ufw-apache.sh
ufw limit ssh
ufw allow 'Apache Full'
ufw --force enable

# files/var/lib/cloud/scripts/per-instance/provision.sh (*)
echo $(date -u) ": System provisioning script is complete." >>/var/log/per-instance.log
echo "[OK] $CHEVERETO_LABEL provisioned!"
echo "Continue the process at http://$PROJECT_IP"
