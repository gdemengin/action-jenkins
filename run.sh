#!/bin/bash

set -e

function usage() {
    echo "usage: $0 [options] [--] <entrypoint parameters>"
    echo "options:"
    echo "  --version <version>"
    echo "  --keepalive"
    echo "  --standalone"
    echo "  --no-cache"
    echo "  --docker-run-arg <arg>"
    echo "  --plugins <plugins file>"
    echo "  --init_groovy <init.groovy.d folder>"
    echo "  --entrypoint <entrypoint folder>"
}

KEEPALIVE=false
STANDALONE=false
DOCKER_RUN_ARG=
DOCKER_BUILD_ARG=
VERSION=lts

while [ $# -gt 0 ]; do
    case "$1" in
        -h|--help) usage; exit 0;;
        --version) VERSION=$2; shift 2;;
        --keepalive) KEEPALIVE=true; shift;;
        --standalone) STANDALONE=true; shift;;
        --no-cache) DOCKER_BUILD_ARG="--pull --no-cache"; shift;;
        --docker-run-arg) DOCKER_RUN_ARG="$2"; shift 2;;
        --plugins) export INPUT_PLUGINS=$2; shift 2;;
        --init_groovy) export INPUT_INIT_GROOVY=$2; shift 2;;
        --entrypoint) export INPUT_ENTRYPOINT=$2; shift 2;;
        --) shift; break;;
        *) echo "unknown parameter $1"; usage; exit 1;;
    esac
done

# input params
export GITHUB_WORKSPACE=/workspace
export INPUT_DUMP_VERSION_PATH=\${GITHUB_WORKSPACE}/.version

export INPUT_KEEPALIVE=${KEEPALIVE}
export INPUT_STANDALONE=${STANDALONE}

cd $(dirname $0)/
./prepare.sh ${VERSION} .jenkins
cd .jenkins

IMAGE_NAME=jenkins-${VERSION}
docker build ${DOCKER_BUILD_ARG} -t ${IMAGE_NAME} .

set -x

docker run -it --rm \
  --workdir ${GITHUB_WORKSPACE} \
  -e GITHUB_WORKSPACE \
  -e CI=false \
  -v $(pwd)/..:${GITHUB_WORKSPACE} \
  ${DOCKER_RUN_ARG} ${IMAGE_NAME} "$@"
