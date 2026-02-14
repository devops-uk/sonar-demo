pipeline {
    agent {
        kubernetes {
            yaml """
apiVersion: v1
kind: Pod
spec:
  containers:
  - name: maven
    image: maven:3.9.3-openjdk-11
    command:
    - cat
    tty: true
"""
        }
    }
    stages {
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
                    withSonarQubeEnv('sonar-server') {
                        sh 'mvn sonar:sonar -Dsonar.projectKey=sonar-demo'
                    }
                }
            }
        }
    }
}

