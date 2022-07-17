#!/bin/bash

set -e

[ $# -eq 2 ] || {
    echo "ERROR wrong numbre of parameters"
    echo "usage: $0 <jenkins version> <build folder>"
    exit 1
}

VERSION=$1
TARGET=$2

# prepare folder to build docker container
# and run it as action
rm -rf ./${TARGET}
cp -r ./src ./${TARGET}/

> ./${TARGET}/env

function set_input_env() {
    if [ -z ${!1+x} ]; then
        # env var $1 is unset
        echo export $1=\"$2\" >> ./${TARGET}/env
    else
        echo export $1=\"${!1}\" >> ./${TARGET}/env
    fi
}
set_input_env INPUT_JAVA_OPTS "-Djenkins.install.runSetupWizard=false"
set_input_env INPUT_PLUGINS_FORCE_UPGRADE true
set_input_env INPUT_TRY_UPGRADE_IF_NO_MARKER true
set_input_env INPUT_STARTUP_TIMEOUT 300
set_input_env INPUT_SHUTDOWN_TIMEOUT 60
set_input_env INPUT_ADMIN_USERNAME jenkins
set_input_env INPUT_ADMIN_PASSWORD jenkins
set_input_env INPUT_MASTER_NUM_EXECUTORS 4
set_input_env INPUT_MASTER_LABELS ""
set_input_env INPUT_KEEPALIVE false
set_input_env INPUT_STANDALONE false

cat ./${TARGET}/env

mkdir -p ./${TARGET}/jenkins_home
# avoid diocker issue when copying empty folders
touch ./${TARGET}/jenkins_home/.notempty

if [ ${VERSION} == "last-good-version" ]; then
    VERSION=$(cat last-good-version/version)
    cp last-good-version/plugins.txt ${TARGET}/
fi

sed "s|FROM jenkins/jenkins:lts|FROM jenkins/jenkins:${VERSION}|" ./${TARGET}/Dockerfile > ./${TARGET}/Dockerfile.tmp
mv ./${TARGET}/Dockerfile.tmp ./${TARGET}/Dockerfile

exit 0

