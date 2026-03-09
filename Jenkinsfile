pipeline {
    agent any

    environment {

        BLUE_SERVER = "54.255.243.8"
        GREEN_SERVER = "3.0.90.147"

        BLUE_TG = "arn:aws:elasticloadbalancing:ap-southeast-1:265974217143:targetgroup/blue-target-group/28774fc982eb3590"
        GREEN_TG = "arn:aws:elasticloadbalancing:ap-southeast-1:265974217143:targetgroup/green-target-group/928a36c922e41275"

        LISTENER_ARN = "arn:aws:elasticloadbalancing:ap-southeast-1:265974217143:loadbalancer/app/application-load-balancer/e0ac9b61afa64029"
    }

    stages {

        stage('Clone Repository') {
            steps {
                git 'https://github.com/ganesh-966/blue-green-jenkins-deployment.git'
            }
        }

        stage('Detect Active Environment') {
            steps {
                script {

                    ACTIVE = sh(
                        script: "aws elbv2 describe-listeners --listener-arn $LISTENER_ARN | grep blue",
                        returnStdout: true
                    ).trim()

                    if (ACTIVE) {

                        env.TARGET_SERVER = GREEN_SERVER
                        env.TARGET_TG = GREEN_TG
                        env.OLD_TG = BLUE_TG

                    } else {

                        env.TARGET_SERVER = BLUE_SERVER
                        env.TARGET_TG = BLUE_TG
                        env.OLD_TG = GREEN_TG
                    }
                }
            }
        }

        stage('Deploy Application') {
            steps {
                sh "bash scripts/deploy.sh $TARGET_SERVER"
            }
        }

        stage('Health Check') {
            steps {
                script {
                    try {

                        sh "bash scripts/health_check.sh $TARGET_SERVER"

                    } catch (Exception e) {

                        sh "bash scripts/rollback.sh $OLD_TG $LISTENER_ARN"
                        error("Health check failed. Rollback executed.")
                    }
                }
            }
        }

        stage('Switch Traffic') {
            steps {
                sh "bash scripts/switch_traffic.sh $TARGET_TG $LISTENER_ARN"
            }
        }

    }

    post {

        success {
            echo "Deployment successful with zero downtime"
        }

        failure {
            echo "Pipeline failed"
        }

    }
}