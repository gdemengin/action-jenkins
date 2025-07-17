#!/bin/bash
# same test as .github/workflows/main.yml

set -e

cd $(dirname $0)/..

for version in lts last-good-version 2.479.3 2.319.3 2.190.1 2.89.4; do
    echo "test on jenkins-${version}"

    # test lts and lgv with their plugin list (fixed for lgv)
    if [ "${version}" == "lts" ] || [ "${version}" == "last-good-version" ]; then
        echo "test jenkins-${version} with default plugin list"
        ./run.sh --version ${version}
    fi

    # tests all with no plugins
    echo "test jenkins-${version} with empty plugin list"
    ./run.sh --version ${version} --plugins test/empty-plugins.txt

    # test old versions of jenkins with fixed versions of plugins
    if [ "${version}" == "2.190.1" ]; then
        echo "test jenkins-${version} with fixed versions of plugins"
        ./run.sh --version ${version} --plugins test/plugins-${version}.txt
    fi
    echo "end of test on jenkins-${version}"
done

echo "Happy End!"
