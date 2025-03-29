def remote = [:]
def git_url = "git@github.com:chesnokov70/node-app.git"
pipeline {
  agent any
  parameters {
    gitParameter (name: 'revision', type: 'PT_BRANCH')
  }
  environment {
    REGISTRY = "chesnokov70/node-app"
    TF_VAR_PUBLIC_IP = ""
    SSH_KEY = credentials('ssh_instance_key')
    TOKEN = credentials('hub_token')
  }
  stages {

    stage ('Build and push') {
      steps {
        script {
          sh """ 
          TF_VAR_PUBLIC_IP=$(terraform output -raw ec2_public_ip)
          echo "Public IP: $TF_VAR_PUBLIC_IP"
          """
        }
      }
    }

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
          scp /var/lib/jenkins/workspace/My_Lessons_Folder/node-app/docker-compose.tmpl root@${TF_VAR_PUBLIC_IP}:/opt
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
          envsubst < docker-compose.tmpl | sudo tee docker-compose.yaml
          docker compose up -d
          """
        }
      }
    }
  }    
} 
