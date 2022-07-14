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
    def versionStr = "Jenkins Instance Version : ${instanceVersion}\n"

    def plugins = plugins()
    plugins.sort{ it['shortName'] }

    def pluginsVersionsStr = "Plugins : \n"
    pluginsVersionsStr += plugins.collect{
        "\t${it.displayName} (${it.shortName}) v${it.version}"
    }.join('\n') + '\n'

    def pluginsShortVersionsStr = plugins.collect{
         "${it.shortName}:${it.version}"
    }.join('\n') + '\n'

    def fullVersionStr = "${versionStr}${pluginsVersionsStr}"

    print fullVersionStr

    def target = System.getenv('ACTION_JENKINS_VERSION')

    if (target != null) {
        new File(target).mkdirs()
        new File("${target}/version").write(instanceVersion)
        new File("${target}/plugins.txt").write(pluginsShortVersionsStr)
        // human readable
        new File("${target}/versions.txt").write(fullVersionStr)
    }
}

dumpVersion()
