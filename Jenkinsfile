pipeline {
    agent {
        node {
            label 'maven'
        }
    }

environment {
    PATH_PLUS_EXTRA = '/opt/apache-maven-3.9.6/bin:$PATH'
}
    stages {
        stage('build') {
            steps {
                sh "echo $PATH"
                //sh 'mvn clean deploy'
            }
        }
    }
}
