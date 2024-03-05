pipeline {
    agent any
    
    environment {
        DOCKERHUB_USERNAME = credentials('DOCKERHUB_USERNAME')
        DOCKER_HUB_TOKEN = credentials('DOCKER_HUB_TOKEN')
        AWS_ACCESS_KEY_ID = credentials('AWS_ACCESS_KEY_ID')
        AWS_SECRET_ACCESS_KEY = credentials('AWS_SECRET_ACCESS_KEY')
    }
    
    stages {
        stage('Build and Upload Docker Image') {
            when {
                anyOf {
                    branch 'master'
                    branch '*'
                }
            }
            
            steps {
                script {
                    checkout scm
                    
                    sh 'which docker'
                    
                    withDockerRegistry([credentialsId: DOCKERHUB_USERNAME, url: "https://index.docker.io/v1/"]) {
                        sh "docker build -t mern-fe:$(git log -1 --pretty=format:%h) ./client"
                        sh "docker build -t mern-be:$(git log -1 --pretty=format:%h) ./server"
                        
                        sh """
                        docker tag mern-fe:$(git log -1 --pretty=format:%h) dpaktamang/mern-ecomerce-fe:$(git log -1 --pretty=format:%h)
                        docker tag mern-be:$(git log -1 --pretty=format:%h) dpaktamang/mern-ecomerce-be:$(git log -1 --pretty=format:%h)
                        docker push dpaktamang/mern-ecomerce-fe:$(git log -1 --pretty=format:%h)
                        docker push dpaktamang/mern-ecomerce-be:$(git log -1 --pretty=format:%h)
                        """
                    }
                }
            }
        }
        
        stage('Deploy') {
            when {
                branch 'master'
            }
            
            steps {
                script {
                    checkout scm
                    
                    withAWS(credentials: 'aws_credentials', region: 'us-east-1') {
                        sh 'sudo apt-get update'
                        sh 'sudo apt-get install -y expect'
                        
                        def public_ip = sh(script: 'aws ec2 describe-instances --filters "Name=tag-value,Values=mern-instance" --query "Reservations[*].Instances[*].PublicIpAddress" --output text', returnStdout: true).trim()
                        
                        sleep(10)
                        
                        dir('.github/IaC') {
                            sh 'terraform init'
                            sh 'terraform validate'
                            sh 'terraform plan'
                            sh 'terraform apply -auto-approve'
                        }
                        
                        dir('.github/scripts') {
                            sh './deploy.sh $public_ip'
                        }
                    }
                }
            }
        }
    }
}
