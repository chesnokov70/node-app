def remote = [:]
def git_url = "git@github.com:chesnokov70/node-app.git"
pipeline {
  agent any
  parameters {
    gitParameter (name: 'revision', type: 'PT_BRANCH')
  }
  environment {
    EC2_USER = "ubuntu"
    REGISTRY = "chesnokov70/node-app"
    HOST = '3.95.164.182'
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
         mkdir -p /var/lib/jenkins/.ssh
         ssh-keyscan -H ${HOST} >> /var/lib/jenkins/.ssh/known_hosts
         chmod 600 /var/lib/jenkins/.ssh/known_hosts
         scp /var/lib/jenkins/workspace/My_Lessons_Folder/node-app/docker-compose.tmpl root@${HOST}:/opt
         """
        }
      }
    }
    
    stage ('Deploy node-app') {
      steps {
        script {
          sshCommand remote: remote, command: """
          export APP_IMG="${env.REGISTRY}:${env.BUILD_ID}"
          cd /opt
          envsubst < promtail-config.yaml | sudo tee /etc/promtail/config.yaml
          envsubst < docker-compose.tmpl | sudo tee docker-compose.yaml
          docker compose up -d
          """
        }
      }
    }
  }    
} 