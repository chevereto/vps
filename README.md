# Chevereto VPS

> 🔔 [Subscribe](https://chv.to/newsletter) to don't miss any update regarding Chevereto.

<img alt="Chevereto" src="LOGO.svg" width="100%">

[![Community](https://img.shields.io/badge/chv.to-community-blue?style=flat-square)](https://chv.to/community)

Collection of universal bash scripts to install Chevereto in any VPS. We strongly recommend [Vultr](https://chv.to/vultr) and [Linode](https://chv.to/linode).

## Instructions

* Login to your VPS
* `cd` into the website project folder
* Run the following script(s)

## Ubuntu

> **Note**: Ubuntu LTS 22.04 is recommended. If you run other system you may need to alter the scripts. Feel free to contribute.

### Prepare

The [`prepare.sh`](ubuntu/22.04/prepare.sh) script install the system stack (web server, database, packages, composer) on Ubuntu.

Before running this script:

* Reboot your VPS (to apply kernel updates)
* Make sure to change `22.04` to your match your Ubuntu LTS

```sh
bash <(curl -s https://raw.githubusercontent.com/chevereto/vps/4.0/ubuntu/22.04/prepare.sh)
```

## Common

The scripts at `common/` will work under any `unix-like` system. The only requirements are `curl` and `unzip`. For debian-based systems scripts `new.sh` and `get.sh` will fix filesystem permissions for `www-data`.

### New

The [`new.sh`](common/new.sh) script downloads Chevereto and its dependencies. It configures Apache HTTP Web server, MySQL, cron and it prepares Chevereto for [HTTP setup](https://v4-docs.chevereto.com/application/installing/installation.html#http-setup).

This is intended to brand new installations and it should run after [prepare](#prepare) as it assumes that the system stack is ready.

```sh
bash <(curl -s https://raw.githubusercontent.com/chevereto/vps/4.0/common/new.sh)
```

#### Notes

On the server:

* The web root is located at `/var/www/html`
* The MySQL root password is saved at `/root/.mysql_password`
* Logs are at `/var/log/apache2`

IMPORTANT:

* Secure your database by running `mysql_secure_installation`

### Get

The [`get.sh`](common/get.sh) script download and extracts Chevereto in the current working folder.

This can be used in any context where the system stack is installed.

```sh
bash <(curl -s https://raw.githubusercontent.com/chevereto/vps/4.0/common/get.sh)
```

### Cloudflare remote IP

The [`cf-remoteip.sh`](common/cf-remoteip.sh) script syncs the known IPs for CloudFlare remote IP. This **must** be used if you are using CloudFlare.

> **Warning**: If you use CloudFlare and not complete this setup, your Chevereto installation won't be able to retrieve the real visitor IP.

```sh
bash <(curl -s https://raw.githubusercontent.com/chevereto/vps/4.0/common/cf-remoteip.sh)
```

Save the above script in your VPS and run it on cron to keep these ranges auto updated.

```sh
curl -f -SOJL \
    --output-dir /etc/apache2 \
    https://raw.githubusercontent.com/chevereto/vps/4.0/common/cf-remoteip.sh
```

```sh
cat >/etc/cron.d/cf-remoteip <<EOM
30 3 * * * /etc/apache2/cf-remoteip.sh >/dev/null 2>&1
EOM
```

## HTTPS setup

Run the following command to get https with certbot. Mind to change `example.com` with the target domain(s).

```sh
certbot --apache -d example.com -d www.example.com
```
