#!/bin/bash

set -e

function usage() {
    echo "usage: $0 [options] [--] <entrypoint parameters>"
    echo "options:"
    echo "  --version <version>"
    echo "  --dump-version-path <relative path>"
    echo "  --keepalive"
    echo "  --standalone"
    echo "  --workspace <workspace>"
    echo "  --no-cache"
    echo "  --docker-run-arg <arg>"
    echo "  --plugins <plugins file>"
    echo "  --init_groovy <init.groovy.d folder>"
    echo "  --entrypoint <entrypoint folder>"
}

DOCKER_RUN_ARG=
DOCKER_BUILD_ARG=
VERSION=lts
WORKSPACE=$(pwd)/..

while [ $# -gt 0 ]; do
    case "$1" in
        -h|--help) usage; exit 0;;
        --version) VERSION=$2; shift 2;;
        --dump-version-path) export INPUT_DUMP_VERSION_PATH="\${GITHUB_WORKSPACE}/$2"; shift 2 ;;
        --keepalive) export INPUT_KEEPALIVE=true; shift ;;
        --standalone) export INPUT_STANDALONE=true; shift ;;
        --workspace) WORKSPACE="$2"; shift 2;;
        --no-cache) DOCKER_BUILD_ARG="--pull --no-cache"; shift;;
        --docker-run-arg) DOCKER_RUN_ARG="$2"; shift 2;;
        --plugins) export INPUT_PLUGINS="$2"; shift 2;;
        --init_groovy) export INPUT_INIT_GROOVY="$2"; shift 2;;
        --entrypoint) export INPUT_ENTRYPOINT="$2"; shift 2;;
        --) shift; break;;
        *) echo "unknown parameter $1"; usage; exit 1;;
    esac
done

WORKDIR=$(dirname $0)
${WORKDIR}/prepare.sh ${VERSION}

IMAGE_NAME=jenkins-${VERSION}
docker build ${DOCKER_BUILD_ARG} -t ${IMAGE_NAME} ${WORKDIR}/.jenkins/.

set -x

docker run -it --rm \
  --workdir /workspace \
  -e GITHUB_WORKSPACE=/workspace \
  -e CI=false \
  -v ${WORKSPACE}:/workspace \
  ${DOCKER_RUN_ARG} ${IMAGE_NAME} "$@"
