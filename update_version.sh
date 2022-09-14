#!/bin/bash

set -e

# update with .version

[ $# -eq 1 ] || {
    echo "ERROR wrong number of arguments"
    echo "usage: $0 <source version dir> <target>"
    exit 1
}

source=$1
target=last-good-version

rm -rf ${target}
cp -r ${source} ${target}

if [ ! -e ./${target}/version ]; then
    echo "ERROR ./${target}/version missing"
    exit 1
fi

#url=https://raw.githubusercontent.com/jenkins-infra/jenkins.io/master/content/_data/changelogs/lts.yml
#{
#    echo "# lts versions"
#    echo "# ${url}"
#    curl -sSLf ${url} |egrep "^- version" | sed 's/- version: //g' | sed 's/"//g' | sed "s/'//g"
#} > lts.txt

url=https://raw.githubusercontent.com/jenkinsci/jenkins/master/core/src/main/resources/jenkins/install/platform-plugins.json
{
    echo "# default plugins suggested in setupwizard"
    echo "# ${url}"
    curl -sSLf ${url} | grep '"suggested": true' | sed 's/.*"name": "//g' | sed 's/",.*$//g' | sort
} > src/plugins.txt


NEW_BADGE="[![${target}/versions.txt](https://img.shields.io/badge/jenkins-$(cat ${target}/version)-blue.svg)](${target}/versions.txt)"
sed "s|\[\!\[${target}/versions.txt\].*$|${NEW_BADGE}|" README.md > README.md.tmp
mv README.md.tmp README.md

exit 0
