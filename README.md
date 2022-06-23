# Chevereto VPS

> 🔔 [Subscribe](https://chv.to/newsletter) to don't miss any update regarding Chevereto.

<img alt="Chevereto" src="LOGO.svg" width="100%">

[![Community](https://img.shields.io/badge/chv.to-community-blue?style=flat-square)](https://chv.to/community)

Universal bash scripts to install Chevereto in any VPS (Ubuntu).

## New

This is intended to brand new servers. Refer to [Install](#install) if you only need to provide/update the application files.

* Get a new VPS instance running Ubuntu 22.04 (20.04 minimum)
* Login to your VPS
* Run the following command

```sh
bash <(curl -s https://raw.githubusercontent.com/chevereto/vps/4.0/ubuntu-20.04/new.sh)
```

* Click on the URL at the end of the process
* Profit!

### Notes

On the server:

* The default web root is located at `/var/www/html`
* The MySQL root password is saved at `/root/.mysql_password`
* To configure HTTPS run `certbot --apache -d example.com -d www.example.com`

IMPORTANT:

* Secure your database by running `mysql_secure_installation`
* Setup email delivery at `http://localhost/dashboard/settings/email`

### Troubleshooting

* `E: Unable to lock directory /var/lib/apt/lists/`

Your VPS may be installing updates on boot. Give it a few minutes before running the command and try again later.

## Install

This is intended for existing servers, where you don't require to install the server requirements (web server, database, update packages). The `install.sh` bash script only downloads the application files and its dependencies.

* Login to your VPS
* Run the following command

```sh
bash <(curl -s https://raw.githubusercontent.com/chevereto/vps/4.0/ubuntu-20.04/install.sh)
```
