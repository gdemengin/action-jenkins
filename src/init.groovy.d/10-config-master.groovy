import jenkins.model.*

def executors = System.getenv("INPUT_MASTER_NUM_EXECUTORS")
def labels = System.getenv("INPUT_MASTER_LABELS")

assert executors != null, 'missing env var INPUT_MASTER_NUM_EXECUTORS'
assert executors.isInteger(), 'env var INPUT_MASTER_NUM_EXECUTORS is not an integer'
assert labels != null, 'missing env var INPUT_MASTER_LABELS'

Jenkins.instance.setNumExecutors(executors.toInteger())
Jenkins.instance.setLabelString(labels)
