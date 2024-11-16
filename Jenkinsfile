pipeline {
    agent any

    stages {
        /*
        stage('Build') {
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
                    ls -lart
            '''
            }
        }
        */
        stage('Test') {
            agent {
                docker {
                    image 'node:18-alpine'
                    reuseNode true
                }
            }
            steps {
                sh '''
                    test -f build/index.html
                    ls -la
                    #npm install
                    npm test
            '''
            }
        }
        stage('E2E') {
            agent {
                docker {
                    image 'docker pull mcr.microsoft.com/playwright:v1.48.1-jammy'
                    reuseNode true
                }
            }
            steps {
                sh '''
                    npm install server
                    node_modules/server -s build
                    npx playwright test
            '''
            }
        }
    }
    post {
        always {
            junit 'test-results/junit.xml'
        }
    }
}