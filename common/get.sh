#!/usr/bin/env bash

set -e

# init.sh (start)
PROJECT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" &>/dev/null && pwd)"
WORKING_DIR="$(pwd)"

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
CHEVERETO_VERSION="4"
CHEVERETO_TAG=${CHEVERETO_TAG:-${CHEVERETO_VERSION}}
CHEVERETO_PACKAGE=$CHEVERETO_TAG
CHEVERETO_API_DOWNLOAD="https://chevereto.com/api/download/"
CHEVERETO_LABEL="Chevereto V$CHEVERETO_VERSION"

# Header
cat <<EOM
      __                        __
 ____/ /  ___ _  _____ _______ / /____
/ __/ _ \/ -_) |/ / -_) __/ -_) __/ _ \\
\__/_//_/\__/|___/\__/_/  \__/\__/\___/

EOM

# Ask license
echo -n "$CHEVERETO_LABEL License key (if any): 🔑"
read -s CHEVERETO_LICENSE
echo ""

# Vendor cleanup
rm -rf $WORKING_DIR/app/vendor/*

# Prepare temp dir
rm -rf .temp && mkdir .temp && cd .temp

# Download
curl -f -SOJL \
    -H "License: $CHEVERETO_LICENSE" \
    "${CHEVERETO_API_DOWNLOAD}${CHEVERETO_PACKAGE}"

# Extract
unzip -oq *.zip -d $WORKING_DIR
cd -
rm -rf .temp

# chown www-data
if id "www-data" &>/dev/null; then
    chown -R www-data: $WORKING_DIR
else
    echo '[NOTICE] www-data user not found, skipping ownership change'
fi

echo "[OK] $CHEVERETO_LABEL files provisioned!"
