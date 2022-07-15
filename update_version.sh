#!/bin/bash

set -e

# update with .version

[ $# -eq 1 ] || {
    echo "ERROR wrong number of arguments"
    echo "usage: $0 <version dir>"
    exit 1
}

source=$1

if [ ! -e ./${source}/version ]; then
    echo "ERROR ./${source}/version missing"
    exit 1
fi

NEW_BADGE="[![${source}/versions.txt](https://img.shields.io/badge/jenkins-$(cat .version/version)-blue.svg)](${source}/versions.txt)"
sed "s|\[\!\[${source}/versions.txt\].*$|${NEW_BADGE}|" README.md > README.md.tmp
mv README.md.tmp README.md

exit 0
