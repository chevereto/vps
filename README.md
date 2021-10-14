# Chevereto VPS

Universal  shell script to install Chevereto in any VPS (Ubuntu).

## 1 Minute setup

* Get a new VPS instance running Ubuntu 20.04
* Login to your VPS
* Run the following command

```sh
curl -s https://raw.githubusercontent.com/chevereto/vps/main/bash.sh | bash
```

* Click on the installer URL at the end of the process

## Troubleshooting

* `E: Unable to lock directory /var/lib/apt/lists/`

Your VPS may be installing updates on boot. Give it a few minutes before running the command and try again later.
