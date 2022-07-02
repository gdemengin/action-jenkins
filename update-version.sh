#!/bin/bash

set -e

# update with .version

[ $# -eq 3 ] || {
    echo "ERROR wrong number of arguments"
    echo "usage: $0 <source> <source ver> <dest>"
    exit 1
}

source=$1
ver=$2
dest=$3

if [ ! -e ./${source}/.version ]; then
    echo "ERROR ./${source}/.version missing: please run jenkins-${ver} test first"
    exit 1
fi

rm -rf ./${dest}/
cp -r ./${source}/ ./${dest}/
rm -rf ./${dest}/.version
cp -f ./${source}/.version/plugins.txt ./${dest}/
cp -f ./${source}/.version/versions.txt ./${dest}/

sed "s|FROM jenkins/jenkins:${ver}|FROM jenkins/jenkins:$(cat ./${source}/.version/version)|" ./${dest}/Dockerfile > ./${dest}/Dockerfile.tmp
mv ./${dest}/Dockerfile.tmp ./${dest}/Dockerfile

exit 0
