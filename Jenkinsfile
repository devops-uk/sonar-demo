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
    command: ["cat"]
    tty: true

  - name: kaniko
    image: gcr.io/kaniko-project/executor:v1.23.2-debug
    command:
    - /bin/sh
    - -c
    - "sleep 365d"
    volumeMounts:
    - name: docker-config
      mountPath: /kaniko/.docker

  volumes:
  - name: docker-config
    secret:
      secretName: nexus-docker
      items:
      - key: .dockerconfigjson
        path: config.json
"""
    }
  }

  environment {
    REGISTRY = "nexus-nexus-repository-manager.nexus.svc.cluster.local:5000"
    IMAGE    = "sonar-demo"
    TAG      = "${BUILD_NUMBER}"
    FULL_IMG = "${REGISTRY}/${IMAGE}:${TAG}"
  }

  stages {

    stage('Checkout') {
      steps {
        git branch: 'main', url: 'https://github.com/devops-uk/sonar-demo.git'
      }
    }

    stage('Build JAR') {
      steps {
        container('maven') {
          sh 'mvn -DskipTests package'
        }
      }
    }

    stage('Kaniko Build & Push') {
      steps {
        container('kaniko') {
          sh """
            /kaniko/executor \
              --context \$(pwd) \
              --dockerfile Dockerfile \
              --destination ${FULL_IMG} \
              --insecure \
              --skip-tls-verify
          """
        }
      }
    }
  }
}
