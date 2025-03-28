def remote = [:]
def git_url = "git@github.com:chesnokov70/node-app.git"
pipeline {
  agent any
  parameters {
    gitParameter (name: 'revision', type: 'PT_BRANCH')
  }
  environment {
    REGISTRY = "chesnokov70/node-app"
    HOST = '3.237.238.159'
    SSH_KEY = credentials('ssh_instance_key')
    TOKEN = credentials('hub_token')
  }
  stages {

   stage('Configure credentials') {
      steps {
        withCredentials([sshUserPrivateKey(credentialsId: 'ssh_instance_key', keyFileVariable: 'private_key', usernameVariable: 'username')]) {
          script {
            remote.name = "${env.HOST}"
            remote.host = "${env.HOST}"
            remote.user = "$username"
            remote.identity = readFile("$private_key")
            remote.allowAnyHosts = true
          }
        }
      }
    }
    
    stage ('Clone repo') {
      steps {
        checkout([$class: 'GitSCM', branches: [[name: "${revision}"]], doGenerateSubmoduleConfigurations: false, extensions: [], submoduleCfg: [], userRemoteConfigs: [[credentialsId: 'ssh_github_access_key', url: "$git_url"]]])
      }
    }
    stage ('Build and push') {
      steps {
        script {
         sh """ 
         docker login -u chesnokov70 -p $TOKEN
         docker build -t "${env.REGISTRY}:${env.BUILD_ID}" .
         docker push "${env.REGISTRY}:${env.BUILD_ID}"
         """
        }
      }
    }
    stage ('Deploy node-app') {
      steps {
        script {
          sshCommand remote: remote, command: """
          export APP_IMG="${env.REGISTRY}:${env.BUILD_ID}"
          # Check if docker-compose.tmpl exists
          if [ -f docker-compose.tmpl ]; then
            envsubst < docker-compose.tmpl | tee docker-compose.yaml
            docker compose up -d
          else
            echo 'docker-compose.tmpl not found!'
            exit 1
          fi
          """
        }
      }
    }
  }    
} 
