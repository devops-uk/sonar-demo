pipeline {
  agent {
    kubernetes {
      yaml """
apiVersion: v1
kind: Pod
spec:
  serviceAccountName: jenkins-deployer
  automountServiceAccountToken: true

  containers:
  - name: maven
    image: maven:3.9.9-eclipse-temurin-17
    command: ["cat"]
    tty: true
    resources:
      requests:
        cpu: "500m"
        memory: "1Gi"
      limits:
        cpu: "2"
        memory: "2Gi"

  - name: kaniko
    image: gcr.io/kaniko-project/executor:v1.23.2-debug
    command:
    - /bin/sh
    - -c
    - "sleep 365d"
    volumeMounts:
    - name: docker-config
      mountPath: /kaniko/.docker
    resources:
      requests:
        cpu: "500m"
        memory: "1Gi"
      limits:
        cpu: "2"
        memory: "2Gi"

  - name: kubectl
    image: dtzar/helm-kubectl:3.15.3
    command:
    - /bin/sh
    - -c
    - "sleep 365d"
    tty: true
    resources:
      requests:
        cpu: "100m"
        memory: "128Mi"
      limits:
        cpu: "500m"
        memory: "256Mi"

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
    REGISTRY = "10.100.247.93:5000"
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

    stage('Deploy to On-Prem K8s') {
      steps {
        container('kubectl') {
          sh """
            kubectl -n apps apply -f sonar-demo-k8s.yaml
            kubectl -n apps set image deployment/sonar-demo sonar-demo=${FULL_IMG}
            kubectl -n apps rollout status deployment/sonar-demo --timeout=180s
            kubectl -n apps get pods -o wide
          """
        }
      }
    }
  }
}
