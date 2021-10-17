#!/bin/bash

set -e

function usage() {
    echo "usage: $0 [--keepalive] [--standalone] [--no-cache] [--docker-run-arg <arg>] [--] <entrypoint parameters>"
}

KEEPALIVE=false
STANDALONE=false
DOCKER_RUN_ARG=
DOCKER_BUILD_ARG=

while [ $# -gt 0 ]; do
    case "$1" in
        -h|--help) usage; exit 0;;
        --keepalive) KEEPALIVE=true; shift;;
        --standalone) STANDALONE=true; shift;;
        --no-cache) DOCKER_BUILD_ARG="--pull --no-cache"; shift;;
        --docker-run-arg) DOCKER_RUN_ARG="$2"; shift 2;;
        --) shift; break;;
        *) echo "unknown parameter $1"; usage; exit 1;;
    esac
done

BUILD_DIR=$(dirname $0)
IMAGE_NAME=$(basename ${BUILD_DIR})

cd ${BUILD_DIR}

docker build ${DOCKER_BUILD_ARG} -t ${IMAGE_NAME} .

export ACTION_JENKINS_KEEPALIVE=${KEEPALIVE}
export ACTION_JENKINS_STANDALONE=${STANDALONE}
export ACTION_JENKINS_WORKSPACE=/workspace
export ACTION_JENKINS_VERSION=/workspace/${IMAGE_NAME}/.version
export ACTION_JENKINS_ADMIN_USERNAME=jenkins
export ACTION_JENKINS_ADMIN_PASSWORD=jenkins
export ACTION_JENKINS_JAVA_OPTS="-Djenkins.install.runSetupWizard=false"
export ACTION_JENKINS_PLUGINS_FORCE_UPGRADE=true
export ACTION_JENKINS_TRY_UPGRADE_IF_NO_MARKER=true
export ACTION_JENKINS_STARTUP_TIMEOUT=300
export ACTION_JENKINS_SHUTDOWN_TIMEOUT=60

docker run -it --rm \
  -e ACTION_JENKINS_KEEPALIVE \
  -e ACTION_JENKINS_STANDALONE \
  -e ACTION_JENKINS_WORKSPACE \
  -e ACTION_JENKINS_VERSION \
  -e ACTION_JENKINS_ADMIN_USERNAME \
  -e ACTION_JENKINS_ADMIN_PASSWORD \
  -e ACTION_JENKINS_JAVA_OPTS \
  -e ACTION_JENKINS_PLUGINS_FORCE_UPGRADE \
  -e ACTION_JENKINS_TRY_UPGRADE_IF_NO_MARKER \
  -e ACTION_JENKINS_STARTUP_TIMEOUT \
  -e ACTION_JENKINS_SHUTDOWN_TIMEOUT \
  -v $(pwd)/..:${ACTION_JENKINS_WORKSPACE} \
  ${DOCKER_RUN_ARG} ${IMAGE_NAME} "$@"
