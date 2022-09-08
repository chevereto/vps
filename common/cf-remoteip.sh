#!/usr/bin/env bash

set -e

CLOUDFLARE_FILE_PATH=${1:-/etc/apache2/conf-enabled/remoteip.conf}
echo "# Cloudflare" >$CLOUDFLARE_FILE_PATH
echo "RemoteIPHeader CF-Connecting-IP" >>$CLOUDFLARE_FILE_PATH
echo "# IPV4" >>$CLOUDFLARE_FILE_PATH
for i in $(curl -s -L https://www.cloudflare.com/ips-v4); do
    echo "RemoteIPTrustedProxy $i" >>$CLOUDFLARE_FILE_PATH
done
echo "# IPV6" >>$CLOUDFLARE_FILE_PATH
for i in $(curl -s -L https://www.cloudflare.com/ips-v6); do
    echo "RemoteIPTrustedProxy $i" >>$CLOUDFLARE_FILE_PATH
done

apachectl configtest && systemctl restart apache2
