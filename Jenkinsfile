pipeline {
    agent any
    parameters {
        choice(name: 'TERRAFORM_ACTION', choices: ['plan', 'apply', 'destroy'], description: 'Choose Terraform action')
    }
    environment {
        AWS_REGION = 'us-east-2' 
    }
    stages {
        stage('Set AWS Credentials') {
            steps {
                withCredentials([[
                    $class: 'AmazonWebServicesCredentialsBinding',
                    credentialsId: 'jenkinses' 
                ]]) {
                    sh '''
                    echo "AWS_ACCESS_KEY_ID: $AWS_ACCESS_KEY_ID"
                    aws sts get-caller-identity
                    '''
                }
            }
        }
        stage('Checkout Code') {
            steps {
                git branch: 'main', url: 'https://github.com/mfnerd/aws_alb' 
            }
        }
        stage('Initialize Terraform') {
            steps {
                sh 'terraform init'
            }
        }
        stage('Run Terraform') {
            steps {
                withCredentials([[
                    $class: 'AmazonWebServicesCredentialsBinding',
                    credentialsId: 'jenkinses'
                ]]) {
                    script {
                        if (params.TERRAFORM_ACTION == 'plan') {
                            sh '''
                            export AWS_ACCESS_KEY_ID=$AWS_ACCESS_KEY_ID
                            export AWS_SECRET_ACCESS_KEY=$AWS_SECRET_ACCESS_KEY
                            terraform plan -out=tfplan
                            '''
                        } else if (params.TERRAFORM_ACTION == 'apply') {
                            input message: "Approve Terraform Apply?", ok: "Deploy"
                            sh '''
                            export AWS_ACCESS_KEY_ID=$AWS_ACCESS_KEY_ID
                            export AWS_SECRET_ACCESS_KEY=$AWS_SECRET_ACCESS_KEY
                            terraform apply -auto-approve tfplan
                            '''
                        } else if (params.TERRAFORM_ACTION == 'destroy') {
                            input message: "Are you sure you want to destroy all resources?", ok: "Destroy"
                            sh '''
                            export AWS_ACCESS_KEY_ID=$AWS_ACCESS_KEY_ID
                            export AWS_SECRET_ACCESS_KEY=$AWS_SECRET_ACCESS_KEY
                            terraform destroy -auto-approve
                            '''
                        }
                    }
                }
            }
        }
    
   
        stage ("Docker Pull Dastardly from Burp Suite container image") {
            steps {
                sh 'docker pull public.ecr.aws/portswigger/dastardly:latest'
            }
        }
        stage ("Docker run Dastardly from Burp Suite Scan") {
            steps {
                cleanWs()
                sh '''
                    docker run --user $(id -u) -v ${WORKSPACE}:${WORKSPACE}:rw \
                    -e BURP_START_URL=https://ginandjuice.shop/ \
                    -e BURP_REPORT_FILE_PATH=${WORKSPACE}/dastardly-report.xml \
                    public.ecr.aws/portswigger/dastardly:latest
                '''
            }
        }
    }
    post {
        always {
            junit testResults: 'dastardly-report.xml', skipPublishingChecks: true
        }
        success {
            echo 'Terraform process completed successfully!'
        }
        failure {
            echo 'Terraform process failed!'
        }
    }
}    
