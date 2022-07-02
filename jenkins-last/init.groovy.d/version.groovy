// dump plugins list and jenkins version to be able to reinstall the exact same one
import jenkins.model.*
import java.io.File

List<java.util.LinkedHashMap> plugins() {
    return Jenkins.instance.pluginManager.plugins.collect {
        [
            displayName: it.getDisplayName(),
            shortName: it.getShortName(),
            version: it.getVersion()
        ]
    }
}

def dumpVersion() {
    def instanceVersion = "${Jenkins.instance.getVersion()}"
    def versionStr = "Jenkins Instance Version : ${instanceVersion}"

    def plugins = plugins()
    plugins.sort{ it['shortName'] }

    def pluginsVersionStr = "Plugins : \n"
    pluginsVersionStr += plugins.collect{
        "\t${it.displayName} (${it.shortName}) v${it.version}"
    }.join('\n')

    def pluginsShortVersion = plugins.collect{ "${it.shortName}:${it.version}" }.join('\n') + '\n'

    def fullVersionStr = "${versionStr}\n${pluginsVersionStr}\n"

    print fullVersionStr

    def target = System.getenv('ACTION_JENKINS_VERSION')

    if (target != null) {
        new File(target).mkdirs()
        new File("${target}/version").write(instanceVersion)
        new File("${target}/plugins.txt").write(pluginsShortVersion)
        // human readable
        new File("${target}/versions.txt").write(fullVersionStr)
    }
}

dumpVersion()
