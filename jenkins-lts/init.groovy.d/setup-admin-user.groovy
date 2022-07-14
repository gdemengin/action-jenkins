import jenkins.model.*
import hudson.security.*

def adminUsername = System.getenv("ACTION_JENKINS_ADMIN_USERNAME") ?: 'jenkins'
def adminPassword = System.getenv("ACTION_JENKINS_ADMIN_PASSWORD") ?: 'jenkins'

def hudsonRealm = new HudsonPrivateSecurityRealm(false)
hudsonRealm.createAccount(adminUsername, adminPassword)
Jenkins.instance.setSecurityRealm(hudsonRealm)

def authorizationStrategy = new FullControlOnceLoggedInAuthorizationStrategy()
authorizationStrategy.setAllowAnonymousRead(false)
Jenkins.instance.setAuthorizationStrategy(authorizationStrategy)

Jenkins.instance.save()
