#!/bin/bash

set -e
set -u

# input parameters INPUT_*
source /entrypoint/input_env.sh

# define init(), check(), $LOGFILES and other evn vars
source /entrypoint/init.sh >> /stdout 2>&1

# default values for env vars if not defined in init.sh
export JAVA_OPTS=${JAVA_OPTS:--Djenkins.install.runSetupWizard=false}
export PLUGINS_FORCE_UPGRADE=${PLUGINS_FORCE_UPGRADE:-false}
export TRY_UPGRADE_IF_NO_MARKER=${TRY_UPGRADE_IF_NO_MARKER:-false}
export STARTUP_TIMEOUT=${STARTUP_TIMEOUT:-300}
export SHUTDOWN_TIMEOUT=${SHUTDOWN_TIMEOUT:-60}


function interruptible_sleep() {
    sleep $1 &
    wait $!
}

function start_jenkins() {
    echo "$(date) starting jenkins instance"

    if [ "${INPUT_STANDALONE}" == "true" ]; then
        # start jenkins in foreground to be only process in container
        /usr/local/bin/jenkins.sh
    else
        /usr/local/bin/jenkins.sh >> /jenkins.log 2>&1 &

        local elapsed=0
        local start=
        local stop=
        local timeout=${STARTUP_TIMEOUT}
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
    local timeout=${SHUTDOWN_TIMEOUT}
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

JENKINS_STARTED=false
function exit_failure() {
    return_code=$?
    if [ "${INPUT_KEEPALIVE}" != "true" ] && [ "${JENKINS_STARTED}" == "true"]; then
        echo "$1 FAILED with code ${return_code}: stop jenkins and exit" >> /stdout 2>&1
        stop_jenkins >> /stdout 2>&1
    elif [ "${JENKINS_STARTED}" == "true"]; then
        echo "$1 FAILED with code ${return_code}" >> /stdout 2>&1
    fi

    # sleep to make sure tailed logs (/stdout, /jenkins.log, etc...) are flushed
    sleep 10
    # one more log just in case flush failed
    echo "$1 FAILED with code ${return_code}"

    if [ "${INPUT_KEEPALIVE}" != "true" ] || [ "${JENKINS_STARTED}" != "true" ]; then
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

if [ "${INPUT_STANDALONE}" == "true" ]; then
    init
    [ "${LOGFILES}" != "" ] && tail -F ${LOGFILES} &
    start_jenkins
else
    > /jenkins.log
    > /stdout
    tail -F /jenkins.log /stdout ${LOGFILES} &
    trap 'interrupt >> /stdout 2>&1;' TERM INT

    init >> /stdout 2>&1 || exit_failure init

    start_jenkins >> /stdout 2>&1 || exit_failure start_jenkins

    interruptible_sleep 10
    check >> /stdout 2>&1 || exit_failure check

    if [ "${INPUT_KEEPALIVE}" != "true" ]; then
        stop_jenkins >> /stdout 2>&1 || exit_failure stop_jenkins
    else
        echo "INPUT_KEEPALIVE=true : keep instance running" >> /stdout 2>&1
        interruptible_sleep infinity
    fi
fi

# sleep to make sure logs are flushed
sleep 10
echo "Happy End!"
