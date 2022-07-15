import jenkins.model.*

// default 4 executors and no label for master node
def executors = (System.getenv("ACTION_JENKINS_MASTER_EXECUTORS") ?: '4').toInteger()
def labels = System.getenv("ACTION_JENKINS_MASTER_LABELS") ?: ''

Jenkins.instance.setNumExecutors(executors)
Jenkins.instance.setLabelString(labels)
