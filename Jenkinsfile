pipeline {
    agent {
        label 'worker'
    }

    stages {
        stage('Build Docker Image') {
            steps {
                script {
                    // Build Docker image
                    def dockerTag = "070387/jenkins:${env.BRANCH_NAME}"
                    sh "docker build -t ${dockerTag} ."
                }
            }
        }
    }

    post {
        success {
            script {
                // Send success status to GitHub
                currentBuild.result = 'SUCCESS'
                updateGitHubCommitStatus('success')
            }
        }
        failure {
            script {
                // Send failure status to GitHub
                currentBuild.result = 'FAILURE'
                updateGitHubCommitStatus('failure')
            }
        }
    }
}

def updateGitHubCommitStatus(status) {
    sh """
        curl -u username:password -H 'Content-Type: application/json' -X POST \
        -d '{"state": "${status}", "context": "Jenkins", "description": "Docker image build status"}' \
        https://api.github.com/repos/prysukha/Homeworks/statuses/\${GIT_COMMIT}
    """
}
