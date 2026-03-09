pipeline {
    agent any

    environment {
        AWS_REGION = 'ap-southeast-1'
        LISTENER_ARN = 'arn:aws:elasticloadbalancing:ap-southeast-1:265974217143:listener/app/application-load-balancer/e0ac9b61afa64029/c5bbfd94b9378fd0'
        BLUE_TG = 'blue-target-group'
        GREEN_TG = 'green-target-group'
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
                    def active = sh(
                        script: "aws elbv2 describe-listeners --listener-arn $LISTENER_ARN --region $AWS_REGION | grep $BLUE_TG || true",
                        returnStdout: true
                    ).trim()

                    if (active) {
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
                echo "Deploying application to ${env.TARGET_ENV} environment"
                sh """
                echo "Deployment step here"
                """
            }
        }

        stage('Health Check') {
            steps {
                echo "Running health checks..."
                sh """
                sleep 10
                echo "Health check passed"
                """
            }
        }

        stage('Switch Traffic') {
            steps {
                script {
                    def TARGET_GROUP = env.TARGET_ENV == "blue" ? env.BLUE_TG : env.GREEN_TG

                    sh """
                    aws elbv2 modify-listener \
                    --listener-arn $LISTENER_ARN \
                    --default-actions Type=forward,TargetGroupArn=$TARGET_GROUP \
                    --region $AWS_REGION
                    """
                }
            }
        }
    }

    post {
        success {
            echo "Blue-Green Deployment Successful"
        }
        failure {
            echo "Pipeline failed"
        }
    }
}