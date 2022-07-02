#!/bin/bash

set -e

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

        while [ $(cat /jenkins.log | grep "Completed initialization" | wc -l) = 0 ]; do
            if [ $(cat /jenkins.log | grep "Jenkins stopped" | wc -l) != 0 ]; then
                echo "jenkins has stopped instead of starting"
                return 1
            fi
            echo "$(date) waiting for jenkins to complete startup"
            sleep 10
        done
        echo ""
        echo "$(date) jenkins instance started"
    fi
}

function stop_jenkins() {
    echo "$(date) stopping jenkins instance"
    sleep 1

    # wait for shutdown
    while [ $(ps -efla | grep java | grep -v grep | wc -l) != 0 ]; do
        echo "$(date) waiting for jenkins to stop"
        ps -efla | grep java | grep -v grep
        killall java
        sleep 10
    done
    echo ""
    echo "$(date) jenkins instance stopped"
}

function exit_failure() {
    return_code=$?
    # sleep to make sure logs are flushed
    sleep 10
    echo "$1 failed with code ${return_code}"
    exit ${return_code}
}

if [ "${ACTION_JENKINS_STANDALONE}" == "true" ]; then
    start_jenkins standalone
else
    > /jenkins.log
    > stdout
    tail -F /jenkins.log stdout &
    tm_start=${ACTION_JENKINS_STARTUP_TIMEOUT:-300}
    tm_stop=${ACTION_JENKINS_SHUTDOWN_TIMEOUT:-60}

    export -f start_jenkins
    export -f stop_jenkins

    timeout ${tm_start} bash -ec "start_jenkins" >> stdout 2>&1 || exit_failure start_jenkins

    # TODO : do the work
    sleep 10
    # work || exit_failure work

    timeout ${tm_stop} bash -ec stop_jenkins >> stdout 2>&1 || exit_failure stop_jenkins
fi

# sleep to make sure logs are flushed
sleep 10
echo "Happy End!"
