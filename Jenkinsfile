pipeline {
    agent {
        kubernetes {
            yaml """
apiVersion: v1
kind: Pod
spec:
  containers:
  - name: maven
    image: maven:3.9.9-eclipse-temurin-17
    command:
    - cat
    tty: true
"""
        }
    }

    environment {
        NEXUS_URL = "http://nexus.local/repository/maven-hosted/"
    }

stage('Checkout') {
    steps {
        git branch: 'main',
            url: 'https://github.com/YOUR-USERNAME/YOUR-REPO.git'
    }
}

        stage('Build') {
            steps {
                container('maven') {
                    sh 'mvn clean package'
                }
            }
        }

        stage('SonarQube Scan') {
            steps {
                container('maven') {
                    withSonarQubeEnv('sonar-server') {
                        sh 'mvn sonar:sonar'
                    }
                }
            }
        }

        stage('Quality Gate') {
            steps {
                timeout(time: 10, unit: 'MINUTES') {
                    waitForQualityGate abortPipeline: true
                }
            }
        }

        stage('Deploy to Nexus') {
            steps {
                container('maven') {
                    withCredentials([usernamePassword(
                        credentialsId: 'nexus-creds',
                        usernameVariable: 'NEXUS_USER',
                        passwordVariable: 'NEXUS_PASS'
                    )]) {

                        sh """
                        mvn deploy \
                          -Dnexus.username=$NEXUS_USER \
                          -Dnexus.password=$NEXUS_PASS
                        """
                    }
                }
            }
        }
    }
}

