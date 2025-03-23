def remoteInstances = []

pipeline {
    agent any
    parameters {
        gitParameter(name: 'revision', type: 'PT_BRANCH')
    }
    environment {
        REGISTRY = "chesnokov70/node-app"
        SSH_KEY = credentials('ssh_instance_key')
        TOKEN = credentials('hub_token')
        TF_STATE_PATH = 'terraform'
    }
    stages {
        stage('Configure credentials') {
            steps {
                withCredentials([sshUserPrivateKey(credentialsId: 'ssh_instance_key', keyFileVariable: 'private_key', usernameVariable: 'username')]) {
                    script {
                        remoteInstances = []
                    }
                }
            }
        }

        stage('Install Terraform') {
            steps {
            sh '''
            wget -q -O- https://apt.releases.hashicorp.com/gpg | gpg --dearmor | sudo tee /usr/share/keyrings/hashicorp-archive-keyring.gpg > /dev/null
            echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/hashicorp.list
            sudo apt-get update && sudo apt-get install -y terraform
            '''
            }
        }

        stage('Install Docker') {
            steps {
                sh '''
                sudo apt-get update
                sudo apt-get install -y apt-transport-https ca-certificates curl gnupg lsb-release
                curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
                echo \
                  "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu \
                  $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
                sudo apt-get update
                sudo apt-get install -y docker-ce docker-ce-cli containerd.io
                sudo usermod -aG docker jenkins
                '''
            }
        }

        stage('Terraform Init & Apply') {
            steps {
                dir("${TF_STATE_PATH}") {
                    sh """
                    terraform init
                    terraform apply -auto-approve
                    """
                    script {
                        def output = sh(script: "terraform output -json instance_ips", returnStdout: true).trim()
                        def instanceIps = readJSON(text: output)
                        instanceIps.each { ip ->
                            remoteInstances << [
                                name: ip,
                                host: ip,
                                user: 'ubuntu',
                                identity: readFile(env.SSH_KEY),
                                allowAnyHosts: true
                            ]
                        }
                    }
                }
            }
        }

        stage('Clone repo') {
            steps {
                checkout([$class: 'GitSCM', branches: [[name: "${revision}"]], doGenerateSubmoduleConfigurations: false, extensions: [], submoduleCfg: [], userRemoteConfigs: [[credentialsId: 'ssh_github_access_key', url: "$git_url"]]])
            }
        }

        stage('Build and push') {
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

        stage('Copy SSH Key to Instances') {
            steps {
                script {
                    remoteInstances.each { instance ->
                        sshCommand remote: instance, command: """
                        mkdir -p ~/.ssh
                        echo '${readFile(env.SSH_KEY)}' > ~/.ssh/authorized_keys
                        chmod 600 ~/.ssh/authorized_keys
                        """
                    }
                }
            }
        }

        stage('Deploy node-app') {
            steps {
                script {
                    remoteInstances.each { instance ->
                        sshCommand remote: instance, command: """
                        export APP_IMG="${env.REGISTRY}:${env.BUILD_ID}"
                        envsubst < docker-compose.tmpl | tee docker-compose.yaml
                        docker compose up -d
                        """
                    }
                }
            }
        }
    }
}
