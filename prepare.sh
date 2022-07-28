#!/bin/bash

set -e

[ $# -eq 2 ] || {
    echo "ERROR wrong numbre of parameters"
    echo "usage: $0 <jenkins version> <target>"
    exit 1
}

VERSION=$1
SOURCE=$(dirname $0)
TARGET=./$2

# prepare folder to build docker container
# and run it as action
rm -rf ${TARGET}
cp -r ${SOURCE}/src ${TARGET}/

> ${TARGET}/entrypoint/input_env.sh

function set_input_env() {
    if [ -z ${!1+x} ]; then
        # env var $1 is unset
        if [ $# == 2 ]; then
            echo export $1=\"$2\" >> ${TARGET}/entrypoint/input_env.sh
        fi
    else
        echo export $1=\"${!1}\" >> ${TARGET}/entrypoint/input_env.sh
    fi
}
# default values
set_input_env INPUT_MASTER_NUM_EXECUTORS 4
set_input_env INPUT_MASTER_LABELS ""
set_input_env INPUT_KEEPALIVE false
set_input_env INPUT_STANDALONE false
set_input_env INPUT_DUMP_VERSION_PATH ""

cat ${TARGET}/entrypoint/input_env.sh

if [ "${VERSION}" == "last-good-version" ]; then
    VERSION=$(cat last-good-version/version)
    INPUT_PLUGINS=${INPUT_PLUGINS:-last-good-version/plugins.txt}
fi

if [ "${INPUT_PLUGINS}" != "" ]; then
    cp ${INPUT_PLUGINS} ${TARGET}/plugins.txt
fi

if [ "${INPUT_INIT_GROOVY}" != "" ]; then
    cp -r ${INPUT_INIT_GROOVY}/* ${TARGET}/init.groovy.d/
fi

if [ "${INPUT_JENKINS_HOME}" != "" ]; then
    cp -r ${INPUT_JENKINS_HOME} ${TARGET}/jenkins_home/
else
    mkdir -p ${TARGET}/jenkins_home
    # avoid docker issue when copying empty folders
    touch ${TARGET}/jenkins_home/.not_empty
fi

if [ "${INPUT_ENTRYPOINT}" != "" ]; then
    [ -e ${INPUT_ENTRYPOINT}/entrypoint.sh ] && echo "ERROR cannot override entrypoint.sh, use ${INPUT_ENTRYPOINT}/init.sh" && exit 1
    cp -r ${INPUT_ENTRYPOINT}/* ${TARGET}/entrypoint/
fi

sed "s|FROM jenkins/jenkins:lts|FROM jenkins/jenkins:${VERSION}|" ${TARGET}/Dockerfile > ${TARGET}/Dockerfile.tmp
mv ${TARGET}/Dockerfile.tmp ${TARGET}/Dockerfile

exit 0

