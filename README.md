# Chevereto VPS

> 🔔 [Subscribe](https://newsletter.chevereto.com/subscription?f=PmL892XuTdfErVq763PCycJQrvZ8PYc9JbsVUttqiPV1zXt6DDtf7lhepEStqE8LhGs8922ZYmGT7CYjMH5uSx23pL6Q) to don't miss any update regarding Chevereto.

<img alt="Chevereto" src="LOGO.svg" width="100%">

[![Community](https://img.shields.io/badge/chv.to-community-blue?style=flat-square)](https://chv.to/community)

Universal bash script to install Chevereto in any VPS (Ubuntu).

## 1 Minute setup

* Get a new VPS instance running Ubuntu 20.04
* Login to your VPS
* Run the following command

```sh
curl -s https://raw.githubusercontent.com/chevereto/vps/4.0/bash.sh | bash
```

* Click on the installer URL at the end of the process

## Notes

On the server:

* The default web root is located at `/var/www/html`
* The MySQL root password is saved at `/root/.mysql_password`
* To configure HTTPS run `certbot --apache -d example.com -d www.example.com`

IMPORTANT:

* Secure your database by running `mysql_secure_installation`
* Setup email delivery at `http://localhost/dashboard/settings/email`

## Troubleshooting

* `E: Unable to lock directory /var/lib/apt/lists/`

Your VPS may be installing updates on boot. Give it a few minutes before running the command and try again later.