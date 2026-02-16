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

  - name: kubectl
    image: bitnami/kubectl:1.29.0
    command: ["cat"]
    tty: true

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
    // Use the SAME registry endpoint that CRI-O can pull from (ClusterIP)
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
            kubectl create ns apps --dry-run=client -o yaml | kubectl apply -f -

            # apply your manifests (ensure sonar-demo-k8s.yaml is committed to the repo)
            kubectl -n apps apply -f sonar-demo-k8s.yaml

            # set the exact image tag we just pushed
            kubectl -n apps set image deploy/sonar-demo sonar-demo=${FULL_IMG}

            kubectl -n apps rollout status deploy/sonar-demo --timeout=180s
            kubectl -n apps get pods -o wide
          """
        }
      }
    }
  }
}
