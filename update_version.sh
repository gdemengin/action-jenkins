#!/bin/bash

set -e

# update with .version

[ $# -eq 1 ] || {
    echo "ERROR wrong number of arguments"
    echo "usage: $0 <version dir>"
    exit 1
}

source=$1

if [ ! -e ./${source}/version ]; then
    echo "ERROR ./${source}/version missing"
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


NEW_BADGE="[![${source}/versions.txt](https://img.shields.io/badge/jenkins-$(cat ${source}/version)-blue.svg)](${source}/versions.txt)"
sed "s|\[\!\[${source}/versions.txt\].*$|${NEW_BADGE}|" README.md > README.md.tmp
mv README.md.tmp README.md

exit 0
