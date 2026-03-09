pipeline {
    agent any

    environment {
        AWS_REGION = 'ap-southeast-1'

        LISTENER_ARN = 'arn:aws:elasticloadbalancing:ap-southeast-1:265974217143:listener/app/application-load-balancer/e0ac9b61afa64029/c5bbfd94b9378fd0'

        BLUE_TG  = 'arn:aws:elasticloadbalancing:ap-southeast-1:265974217143:targetgroup/blue-target-group/28774fc982eb3590'
        GREEN_TG = 'arn:aws:elasticloadbalancing:ap-southeast-1:265974217143:targetgroup/green-target-group/928a36c922e41275'

        BLUE_SERVER  = '54.255.243.8'
        GREEN_SERVER = '3.0.90.147'
    }

    stages {

        stage('Clone Repository') {
            steps {
                git branch: 'main', url: 'https://github.com/ganesh-966/blue-green-jenkins-deployment.git'
            }
        }

        stage('Detect Active Environment') {
            steps {
                script {
                    def listener = sh(
                        script: """
                        aws elbv2 describe-listeners \
                        --listener-arn ${LISTENER_ARN} \
                        --region ${AWS_REGION}
                        """,
                        returnStdout: true
                    ).trim()

                    if (listener.contains(BLUE_TG)) {
                        env.ACTIVE_ENV = "blue"
                        env.TARGET_ENV = "green"
                    } else {
                        env.ACTIVE_ENV = "green"
                        env.TARGET_ENV = "blue"
                    }

                    echo "Active Environment: ${env.ACTIVE_ENV}"
                    echo "Deploying to: ${env.TARGET_ENV}"
                }
            }
        }

        stage('Deploy Application') {
            steps {
                script {
                    def SERVER = env.TARGET_ENV == "blue" ? env.BLUE_SERVER : env.GREEN_SERVER

                    // Use SSH key stored in Jenkins credentials
                    sshagent(['ssh-key']) {  // Replace 'ssh-key' with your credential ID
                        sh """
                        chmod +x scripts/deploy.sh
                        ./scripts/deploy.sh ${SERVER}
                        """
                    }

                    echo "Deployment completed on ${env.TARGET_ENV} server"
                }
            }
        }

        stage('Health Check') {
            steps {
                script {
                    def SERVER = env.TARGET_ENV == "blue" ? env.BLUE_SERVER : env.GREEN_SERVER

                    sh """
                    chmod +x scripts/health_check.sh
                    ./scripts/health_check.sh ${SERVER}
                    """

                    echo "Health check successful"
                }
            }
        }

        stage('Switch Traffic') {
            steps {
                script {
                    def TARGET_GROUP = env.TARGET_ENV == "blue" ? BLUE_TG : GREEN_TG

                    sh """
                    chmod +x scripts/switch_traffic.sh
                    ./scripts/switch_traffic.sh ${TARGET_GROUP} ${LISTENER_ARN}
                    """

                    echo "Traffic switched to ${env.TARGET_ENV}"
                }
            }
        }
    }

    post {
        success {
            echo "Blue-Green Deployment Successful"
        }

        failure {
            script {
                echo "Deployment failed. Initiating rollback..."

                def OLD_TARGET = env.ACTIVE_ENV == "blue" ? BLUE_TG : GREEN_TG

                sh """
                chmod +x scripts/rollback.sh
                ./scripts/rollback.sh ${OLD_TARGET} ${LISTENER_ARN}
                """

                echo "Rollback completed"
            }
        }
    }
}