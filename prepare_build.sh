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
cp -r jenkins-lts/ ./${TARGET}
rm -rf ./${TARGET}/.version
rm -f ./${TARGET}/action.yml
sed "s|FROM jenkins/jenkins:lts|FROM jenkins/jenkins:${VERSION}|" ./${TARGET}/Dockerfile > ./${TARGET}/Dockerfile.tmp
mv ./${TARGET}/Dockerfile.tmp ./${TARGET}/Dockerfile

exit 0

