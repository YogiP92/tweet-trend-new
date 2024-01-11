pipeline {
    agent {
        node {
            label 'maven'
        }
    }

    environment {
        PATH = "/opt/apache-maven-3.9.6/bin:${PATH}"
    }

    stages {
        stage('build') {
            steps {
                sh "echo $PATH"
                sh 'mvn clean deploy'
            }
        }

    stage('SonarQube analysis') {
    environment {
      scannerHome = tool 'yogip92-sonar-scanner'
    }
    steps{
    withSonarQubeEnv('yogip92-sonarqube-server') { // If you have configured more than one global server connection, you can specify its name extra check
      sh "${scannerHome}/bin/sonar-scanner -X"
    }
    }
  }
}
}
