pipeline {
    agent any

    stages {
        stage('w/o docker') {
            steps {
                sh '''
                    echo "without docker"
                    ls -lart
                    touch container-no.txt
                '''
            }
        }
    }
}