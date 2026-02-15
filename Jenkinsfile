pipeline {
    agent {
        kubernetes {
            yaml """
apiVersion: v1
kind: Pod
spec:
  containers:
  - name: maven
    image: maven:3.9.12-eclipse-temurin-17
    command:
    - cat
    tty: true
"""
        }
    }
    environment {
        // Make sure this matches your Jenkins SonarQube server name
        SONARQUBE_SERVER = 'sonar-server'
    }
    stages {

        stage('Checkout') {
            steps {
                checkout scm
            }
        }

        stage('Build') {
            steps {
                container('maven') {
                    sh 'mvn clean compile'
                }
            }
        }

        stage('Test') {
            steps {
                container('maven') {
                    sh 'mvn test'
                }
            }
        }

        stage('SonarQube Analysis') {
            steps {
                container('maven') {
                    withSonarQubeEnv("${SONARQUBE_SERVER}") {
                        sh 'mvn sonar:sonar -Dsonar.projectKey=sonar-demo'
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
    }
}

