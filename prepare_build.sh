#!/bin/bash

set -e

[ $# -eq 2 ] || {
    echo "ERROR wrong numbre of parameters"
    echo "usage: $0 <jenkins version> <build folder>"
    exit 1
}

VERSION=$1
TARGET=$2

rm -rf ./${TARGET}
mkdir -p ./${TARGET}
cp -r ./* ./${TARGET}/
rm -f ./${TARGET}/action.yml

if [ ${VERSION} == "last-good-version" ]; then
    VERSION=$(cat last-good-version/version)
    cp last-good-version/plugins.txt ${TARGET}/
fi

sed "s|FROM jenkins/jenkins:lts|FROM jenkins/jenkins:${VERSION}|" ./${TARGET}/Dockerfile > ./${TARGET}/Dockerfile.tmp
mv ./${TARGET}/Dockerfile.tmp ./${TARGET}/Dockerfile


exit 0

