#!/bin/bash

composer install --no-scripts
composer run-script package-versions-dump
for file in `git diff master --name-only`; do
    if [[ $file =~ \.php$ ]];
        lib/vendor/bin/phpcs -s -p --colors --extensions=php --standard=PSR12 $file
    fi
done

