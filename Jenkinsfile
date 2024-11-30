pipeline {
    agent any

    // environment {
    //     NETLIFY_SITE_ID = 'ac0d5dd3-32da-4939-ae15-0002d17da60c' // this is got from the netlify website after creating the account and deploy a website
    //     NETLIFY_AUTH_TOKEN = credentials('netlify-token')
    //     REACT_APP_VERSION = "1.2.3"
    // }

    stages {

        stage('Build Docker Image') {
            agent {
                docker {
                    image 'amazon/aws-cli'
                    reuseNode true
                    args "--entrypoint=''" 
                }
            }

            steps {
                echo 'Building Docker image...'
                sh 'amazon-linux-extras install docker' 
                sh 'docker build -t myjenkinsapp .'
            }
        }
        stage('Verify Docker') {
            steps {
                // Ensure Docker is installed and running
                sh '''
                which docker || { echo "Docker not found!"; exit 1; }
                docker --version
                '''
            }
        }
        stage('Create ECR and Push Image') {
            agent {
                docker {
                    image 'amazon/aws-cli'
                    args "--entrypoint=''" // Overrides entrypoint for full flexibility
                    // args '--privileged -v /var/run/docker.sock:/var/run/docker.sock  --entrypoint'
                }
            }
            environment {
                AWS_S3_BUCKET = 'chaganote-demo-v4'
                AWS_DEFAULT_REGION = "us-east-1"
                AWS_ACCOUNT_ID = "871909687521"
                ECR_REPOSITORY = "jenkins-ecr"
            }
            steps {
                withCredentials([usernamePassword(credentialsId: 'my-aws-user', passwordVariable: 'AWS_SECRET_ACCESS_KEY', usernameVariable: 'AWS_ACCESS_KEY_ID')]) {
                    sh '''
                        echo "AWS CLI Version:"
                        aws --version

                        echo "Creating ECR Repository..."
                        aws ecr create-repository --repository-name $ECR_REPOSITORY || echo "Repository may already exist."

                        echo "Logging into ECR..."
                        aws ecr get-login-password --region $AWS_DEFAULT_REGION | docker login --username AWS --password-stdin $AWS_ACCOUNT_ID.dkr.ecr.$AWS_DEFAULT_REGION.amazonaws.com

                        echo "Tagging Docker Image..."
                        docker tag myjenkinsapp:latest $AWS_ACCOUNT_ID.dkr.ecr.$AWS_DEFAULT_REGION.amazonaws.com/$ECR_REPOSITORY:latest

                        echo "Pushing Docker Image to ECR..."
                        docker push $AWS_ACCOUNT_ID.dkr.ecr.$AWS_DEFAULT_REGION.amazonaws.com/$ECR_REPOSITORY:latest
                    '''
                }
            }
        }

        /*stage('Deploy to AWS') {
            agent {
                docker {
                    image 'amazon/aws-cli'
                    args "--entrypoint=''" // "-u root" can be added to be a root
                }
            }
            environment {
                AWS_S3_BUCKET = 'chaganote-demo-v4'
                AWS_DEFAULT_REGION = "us-east-1"
                AWS_SUBNET_1A_ID = "subnet-01555aabb9afb6a6b"
                AWS_SUBNET_1B_ID = "subnet-026a57fbff4808377"
                ECS_SECURITY_GROUP_ID = "sg-026007160ce766055"
                AWS_ECS_CLUSTER = "LearnJenkinsApp-Cluster"
                AWS_ECS_SERVICE_NAME = "LearnJenkinsApp-Service"
                AWS_TASK_DEFINITION_NAME = "LearnJenkinsApp-TaskDefinition-Prod"
            }
            steps {
                withCredentials([usernamePassword(credentialsId: 'my-aws-user', passwordVariable: 'AWS_SECRET_ACCESS_KEY', usernameVariable: 'AWS_ACCESS_KEY_ID')]) {
                    sh '''
                        aws --version
                        aws s3 ls
                        echo "hello s3" > test.txt
                        aws s3 cp test.txt s3://$AWS_S3_BUCKET/test.txt
                        aws s3 sync honey s3://$AWS_S3_BUCKET
                        aws ecs register-task-definition --cli-input-json file://aws/task-definition-prod.json
                        aws ecs create-service \
                            --cluster $AWS_ECS_CLUSTER \
                            --service-name $AWS_ECS_SERVICE_NAME \
                            --task-definition $AWS_TASK_DEFINITION_NAME \
                            --desired-count 1 \
                            --launch-type FARGATE \
                            --platform-version LATEST \
                            --network-configuration "awsvpcConfiguration={subnets=[\"${AWS_SUBNET_1A_ID}",\"${AWS_SUBNET_1B_ID}"],securityGroups=[\"$ECS_SECURITY_GROUP_ID"],assignPublicIp=\"ENABLED\"}"
                    '''}

            }
        } */

        /*stage('Build') {
            agent {
                docker {
                    image 'node:18-alpine'
                    reuseNode true
                }
            }
            steps {
                sh '''
                    ls -la
                    node --version
                    npm --version
                    npm ci
                    npm run build
                    ls -la
                '''
            }
        }
        
        stage('Tests') {
            parallel {
                stage('Unit tests') {
                    agent {
                        docker {
                            image 'node:18-alpine'
                            reuseNode true
                        }
                    }

                    steps {
                        sh '''
                            #test -f build/index.html
                            npm test
                        '''
                    }
                    post {
                        always {
                            junit 'jest-results/junit.xml'
                        }
                    }
                }

                stage('E2E') {
                    agent {
                        docker {
                            image 'mcr.microsoft.com/playwright:v1.39.0-jammy'
                            reuseNode true
                        }
                    }

                    steps {
                        sh '''
                            npm install serve
                            node_modules/.bin/serve -s build &
                            sleep 10
                            npx playwright test  --reporter=html
                        '''
                    }

                    post {
                        always {
                            publishHTML([allowMissing: false, alwaysLinkToLastBuild: false, keepAll: false, reportDir: 'playwright-report', reportFiles: 'index.html', reportName: 'Playwright local', reportTitles: '', useWrapperFileDirectly: true])
                        }
                    }
                }
            }
        }
        stage('Deploy Staging') {
            agent {
                docker {
                    image 'node:18-alpine'
                    reuseNode true
                }
            }
            steps {
                sh '''
                    npm install netlify-cli
                    npm install node-jq
                    ls -lart
                    node_modules/.bin/netlify --version
                    echo 'Deployment to Staging Site ID: $NETLIFY_SITE_ID'
                    node_modules/.bin/netlify status
                    node_modules/.bin/netlify deploy --dir build --json > deploy-output.json
                    node_modules/.bin/node-jq -r '.deploy_url' deploy-output.json
                '''
                script {
                    env.STAGING_URL = sh(script: "node_modules/.bin/node-jq -r '.deploy_url' deploy-output.json", returnStdout: true)
            }
            }
        }
        stage('Staging E2E') {
            agent {
                docker {
                    image 'mcr.microsoft.com/playwright:v1.39.0-jammy'
                    reuseNode true
                }
            }
            environment {
                CI_ENVIRONMENT_URL = "${env.STAGING_URL}"
            }
            steps {
                sh '''
                    npx playwright test  --reporter=html
                '''
            }

            post {
                always {
                    publishHTML([allowMissing: false, alwaysLinkToLastBuild: false, keepAll: false, reportDir: 'playwright-report', reportFiles: 'index.html', reportName: 'Staging E2E', reportTitles: '', useWrapperFileDirectly: true])
                }
            }
        }
        stage('Approval') {
            steps {
                timeout(time: 1, unit: 'MINUTES') {
                    input message: 'Ready to Deploy to production', ok: 'Yes, I am sure'
                }

            }
        }
        stage('Deploy Prod') {
            agent {
                docker {
                    image 'mcr.microsoft.com/playwright:v1.39.0-jammy'
                    reuseNode true
                }
            }
            environment {
                CI_ENVIRONMENT_URL = 'https://velvety-frangollo-422703.netlify.app'
            }
            steps {
                sh '''
                    node --version
                    npm install netlify-cli
                    npm install node-jq
                    ls -lart
                    node_modules/.bin/netlify --version
                    echo 'Deployment to Staging Site ID: $NETLIFY_SITE_ID'
                    node_modules/.bin/netlify status
                    node_modules/.bin/netlify deploy --dir build --prod
                    npx playwright test  --reporter=html
                '''
            }

            post {
                always {
                    publishHTML([allowMissing: false, alwaysLinkToLastBuild: false, keepAll: false, reportDir: 'playwright-report', reportFiles: 'index.html', reportName: 'Prod E2E', reportTitles: '', useWrapperFileDirectly: true])
                }
            }
        } */
    }
}