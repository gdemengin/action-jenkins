#!/bin/bash

set -e

function interruptible_sleep() {
    sleep $1 &
    wait $!
}

function start_jenkins() {
    echo "$(date) starting jenkins instance"
    export JAVA_OPTS=${ACTION_JENKINS_JAVA_OPTS:-"-Djenkins.install.runSetupWizard=false"}
    export PLUGINS_FORCE_UPGRADE=${ACTION_JENKINS_PLUGINS_FORCE_UPGRADE:-true}
    export TRY_UPGRADE_IF_NO_MARKER=${ACTION_JENKINS_TRY_UPGRADE_IF_NO_MARKER:-true}

    if [ "${ACTION_JENKINS_STANDALONE}" == "true" ]; then
        # start jenkins in foreground to be only process in container
        /usr/local/bin/jenkins.sh
    else
        /usr/local/bin/jenkins.sh >> /jenkins.log 2>&1 &

        local elapsed=0
        local start=
        local stop=
        local timeout=${ACTION_JENKINS_STARTUP_TIMEOUT:-300}
        while [ ${elapsed} -lt ${timeout} ] && [ "${start}" == "0" -o "${start}" == "" ]; do
            start=$(cat /jenkins.log | grep 'Completed initialization' | wc -l)
            stop=$(cat /jenkins.log | grep 'Jenkins stopped' | wc -l)
            if [ "${stop}" != "0" ] && [ "${stop}" != "" ]; then
                echo "jenkins has stopped instead of starting"
                return 1
            fi
            echo "$(date) waiting for jenkins to complete startup"
            interruptible_sleep 10
            elapsed=$(( ${elapsed} + 10 ))
        done
        echo ""
        echo "$(date) jenkins instance started"
    fi
}

function stop_jenkins() {
    echo "$(date) stopping jenkins instance"
    sleep 1

    # wait for shutdown
    local elapsed=0
    local stop=$(ps -efla | grep java | grep -v grep | wc -l)
    local timeout=${ACTION_JENKINS_SHUTDOWN_TIMEOUT:-60}
    while [ ${elapsed} -lt ${timeout} ] && [ "${stop}" != "0" ] && [ "${stop}" != "" ]; do
        stop=$(ps -efla | grep java | grep -v grep | wc -l)
        echo "$(date) waiting for jenkins to stop"
        ps -efla | grep java | grep -v grep
        killall java
        interruptible_sleep 10
        elapsed=$(( ${elapsed} + 10 ))
    done
    echo ""
    echo "$(date) jenkins instance stopped"
}

function exit_failure() {
    return_code=$1
    if [ "${ACTION_JENKINS_KEEPALIVE}" != "true" ]; then
        echo "$2 FAILED with code ${return_code}: stop jenkins and exit"
        stop_jenkins
    fi

    # sleep to make sure logs are flushed
    sleep 10
    echo "$2 FAILED with code ${return_code}"

    if [ "${ACTION_JENKINS_KEEPALIVE}" != "true" ]; then
        exit ${return_code}
    fi
}

function interrupt() {
    echo "SIGNAL CAUGHT: stop jenkins and exit"
    trap - INT
    trap - TERM
    stop_jenkins
    # sleep to make sure logs are flushed
    sleep 10
    exit 1
}

if [ "${ACTION_JENKINS_STANDALONE}" == "true" ]; then
    start_jenkins
else
    > /jenkins.log
    > /stdout
    tail -F /jenkins.log /stdout &
    trap 'interrupt >> /stdout 2>&1;' TERM INT

    start_jenkins >> /stdout 2>&1 || exit_failure start_jenkins

    # TODO : do the work
    interruptible_sleep 10
    # work || exit_failure $? work

    if [ "${ACTION_JENKINS_KEEPALIVE}" != "true" ]; then
        stop_jenkins >> /stdout 2>&1 || exit_failure stop_jenkins
    else
        echo "ACTION_JENKINS_KEEPALIVE=true : keep instance running" >> /stdout 2>&1
        interruptible_sleep infinity
    fi
fi

# sleep to make sure logs are flushed
sleep 10
echo "Happy End!"
