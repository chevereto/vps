#!/usr/bin/env bash

set -e

PROJECT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" &>/dev/null && pwd)"
WORKING_DIR="$(pwd)"

paths=(
    "lib/"
    "composer.lock"
    "composer.json"
    "cli.php"
    "app/themes/"
    "app/routes/"
    "app/lib/"
    "app/install/"
    "app/importer/"
    "app/web.php"
    "app/update.php"
    "app/setting-update.php"
    "app/pre-autoload.php"
    "app/loader.php"
    "app/langs.php"
    "app/install.php"
    "app/importing.php"
    "app/htaccess-enforce.php"
    "app/htaccess-checksum.php"
    "app/cron.php"
    "app/chevereto-hook.sample.php"
    "app/app.php"
    "app/apache/d984f0472c79dac505f550a24090b391"
    "app/apache/b9ac088371e0dcad02c417900069bc9b"
    "app/content/system/"
    "app/content/languages/"
    "importing/no-parse/.gitkeep"
    "importing/parse-albums/.gitkeep"
    "importing/parse-users/.gitkeep"
    "sdk/pup.dev.js"
)

for p in "${paths[@]}"; do
    target="$WORKING_DIR/$p"
    if [[ -e "$target" || -L "$target" ]]; then
        echo "Removing: $target"
        rm -rf -- "$target"
    else
        echo "Not found: $target"
    fi
done

echo "Finished."
