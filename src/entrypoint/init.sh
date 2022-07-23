# file sources by entrypoint with custom functions

# files to tail in container's logs
export LOGFILES=

# environment for entrypoint functions
#export JAVA_OPTS=-Djenkins.install.runSetupWizard=false
#export PLUGINS_FORCE_UPGRADE=false
#export TRY_UPGRADE_IF_NO_MARKER=false
#export STARTUP_TIMEOUT=300
#export SHUTDOWN_TIMEOUT=60

# init before jenkins startup
function init() {
    echo "no custom init"
    return 0
}

# checks to perform after jenkins startup
function check() {
    echo "no custom check"
    return 0
}
