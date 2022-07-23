import jenkins.model.*
import hudson.security.*

def adminUsername = 'jenkins'
def adminPassword = 'jenkins'

def hudsonRealm = new HudsonPrivateSecurityRealm(false)
hudsonRealm.createAccount(adminUsername, adminPassword)
Jenkins.instance.setSecurityRealm(hudsonRealm)

def authorizationStrategy = new FullControlOnceLoggedInAuthorizationStrategy()
authorizationStrategy.setAllowAnonymousRead(false)
Jenkins.instance.setAuthorizationStrategy(authorizationStrategy)

Jenkins.instance.save()
