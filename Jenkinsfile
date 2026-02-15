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
        NEXUS_URL = "http://nexus-nexus-repository-manager.nexusus.svc.cluster.local:8081/repository/maven-hosted/"
    }

    stages {

        stage('Checkout') {
            steps {
                git branch: 'main',
                    url: 'https://github.com/devops-uk/sonar-demo.git'
            }
        }

        stage('Build + Sonar Scan') {
            steps {
                container('maven') {
                    withSonarQubeEnv('sonar-server') {
                        withCredentials([string(credentialsId: 'sonar-jenkins-token', variable: 'SONAR_TOKEN')]) {
                            sh '''
                                mvn clean verify sonar:sonar \
                                -Dsonar.token=$SONAR_TOKEN
                            '''
                        }
                    }
                }
            }
        }

        stage('Quality Gate') {
            steps {
                timeout(time: 15, unit: 'MINUTES') {
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
                        sh '''
                            mvn deploy \
                              -Dnexus.username=$NEXUS_USER \
                              -Dnexus.password=$NEXUS_PASS
                        '''
                    }
                }
            }
        }
    }
}
