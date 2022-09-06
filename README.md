# Chevereto VPS

> 🔔 [Subscribe](https://chv.to/newsletter) to don't miss any update regarding Chevereto.

<img alt="Chevereto" src="LOGO.svg" width="100%">

[![Community](https://img.shields.io/badge/chv.to-community-blue?style=flat-square)](https://chv.to/community)

Universal bash scripts to install Chevereto in any Ubuntu VPS (20.04 minimum).

## Instructions

* Login to your VPS
* Run the following script(s)

## Scripts

### Prepare

The `prepare.sh` script install the system stack (web server, database, packages).

Before running this command is recommended to:

* Reboot your VPS
* Run `apt-get upgrade`

```sh
bash <(curl -s https://raw.githubusercontent.com/chevereto/vps/4.0/ubuntu-20.04/prepare.sh)
```

### New

The `new.sh` script downloads Chevereto and its dependencies. It configures Apache HTTP Web server, MySQL, cron and it prepares Chevereto for [HTTP setup](https://v4-docs.chevereto.com/application/installing/installation.html#http-setup).

This is intended to brand new installations and it should run after [prepare](#prepare) as it assumes that the system stack is ready.

```sh
bash <(curl -s https://raw.githubusercontent.com/chevereto/vps/4.0/ubuntu-20.04/new.sh)
```

### Get

The `get.sh` script downloads Chevereto and update it's dependencies.

This can be used in any context where the system stack is installed. It works at `/var/www/html` path.

```sh
bash <(curl -s https://raw.githubusercontent.com/chevereto/vps/4.0/ubuntu-20.04/get.sh)
```

## HTTPS setup

Run the following command to get https with `certbot`. Mind to change `example.com` with the target domain.

```sh
certbot --apache -d example.com -d www.example.com
```

### Notes

On the server:

* The web root is located at `/var/www/html`
* The MySQL root password is saved at `/root/.mysql_password`

IMPORTANT:

* Secure your database by running `mysql_secure_installation`
* Setup email delivery at `http://localhost/dashboard/settings/email`

### Troubleshooting

* `E: Unable to lock directory /var/lib/apt/lists/`

The VPS may be installing updates on boot. Give it a few minutes before running the command(s) and try later.
