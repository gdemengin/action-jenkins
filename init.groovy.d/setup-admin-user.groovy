import jenkins.model.*
import hudson.security.*

def adminUsername = System.getenv("INPUT_ADMIN_USERNAME")
def adminPassword = System.getenv("INPUT_ADMIN_PASSWORD")

assert adminUsername != null, 'missing env var INPUT_ADMIN_USERNAME'
assert adminPassword != null, 'missing env var INPUT_ADMIN_PASSWORD'

def hudsonRealm = new HudsonPrivateSecurityRealm(false)
hudsonRealm.createAccount(adminUsername, adminPassword)
Jenkins.instance.setSecurityRealm(hudsonRealm)

def authorizationStrategy = new FullControlOnceLoggedInAuthorizationStrategy()
authorizationStrategy.setAllowAnonymousRead(false)
Jenkins.instance.setAuthorizationStrategy(authorizationStrategy)

Jenkins.instance.save()
