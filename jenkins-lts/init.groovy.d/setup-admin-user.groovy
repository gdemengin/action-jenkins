import jenkins.model.*
import hudson.security.*

println "--> Setting up admin user"

def adminUsername = System.getenv("ACTION_JENKINS_ADMIN_USERNAME")
def adminPassword = System.getenv("ACTION_JENKINS_ADMIN_PASSWORD")

if (adminUsername == null) {
    adminUsername = 'jenkins'
}
if (adminPassword == null) {
    adminPassword = 'jenkins'
}

def hudsonRealm = new HudsonPrivateSecurityRealm(false)
hudsonRealm.createAccount(adminUsername, adminPassword)
Jenkins.instance.setSecurityRealm(hudsonRealm)

def authorizationStrategy = new FullControlOnceLoggedInAuthorizationStrategy()
authorizationStrategy.setAllowAnonymousRead(false)
Jenkins.instance.setAuthorizationStrategy(authorizationStrategy)

Jenkins.instance.save()
