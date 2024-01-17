//pipeline {
//    agent {
//        node {
//            label 'maven'
//        }
//    }
//
//    environment {
//        PATH = "/opt/apache-maven-3.9.6/bin:${PATH}"
//    }
//
//    stages {
//        stage('build') {
//            steps {
//                sh "echo $PATH"
//                sh 'mvn clean deploy -Dmaven.test.skip=true'
//            }
//        }
//        stage("test"){
//            steps {
//                echo "------------- Unit test started -------------"
//                sh 'mvn surefire-report:report'
//                echo "------------- Unit test completed -------------"
//            } 
//        }
//    
//
//
//    stage('SonarQube analysis') {
//    environment {
//      scannerHome = tool 'yogip92-sonar-scanner'
//    }
//    steps{
//    withSonarQubeEnv('yogip92-sonarqube-server') { // If you have configured more than one global server connection, you can specify its name extra check
//      sh "${scannerHome}/bin/sonar-scanner -X"
//    }
//    }
//  }
//  stage("Quality Gate"){
//    steps {
//        script {
//        timeout(time: 1, unit: 'HOURS') { // Just in case something goes wrong, pipeline will be killed after a timeout
//    def qg = waitForQualityGate() // Reuse taskId previously collected by withSonarQubeEnv
//    if (qg.status != 'OK') {
//      error "Pipeline aborted due to quality gate failure: ${qg.status}"
//    }
//   }
//  }
//    }
//  }
//    }
//    }
//
//
def registry = 'https://yogip92.jfrog.io/'
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
                sh 'mvn clean deploy -Dmaven.test.skip=true'
            }
        }

        stage("test") {
            steps {
                echo "------------- Unit test started -------------"
                sh 'mvn surefire-report:report'
                echo "------------- Unit test completed -------------"
            }
        }

        stage('SonarQube analysis') {
            environment {
                scannerHome = tool 'yogip92-sonar-scanner'
                nodejsHome = tool 'Node.js' // Add this line to reference Node.js installation
            }
            steps {
                script {
                    // Add Node.js to PATH
                    env.PATH = "${nodejsHome}/bin:${env.PATH}"

                    withSonarQubeEnv('yogip92-sonarqube-server') {
                        sh "${scannerHome}/bin/sonar-scanner -X"
                    }
                }
            }
        }

        stage("Quality Gate") {
            steps {
                script {
                    timeout(time: 1, unit: 'HOURS') {
                        def qg = waitForQualityGate()
                        if (qg.status != 'OK') {
                            error "Pipeline aborted due to quality gate failure: ${qg.status}"
                        }
                    }
                }
            }
        }

        stage("Jar Publish") {
            steps {
                script {
                    echo '<--------------- Jar Publish Started --------------->'
                    def server = Artifactory.newServer url: registry + "/artifactory", credentialsId: "artifactory-cred"
                    def properties = "buildid=${env.BUILD_ID},commitid=${GIT_COMMIT}";
                    def uploadSpec = """{
                          "files": [
                            {
                              "pattern": "jarstaging/(*)",
                              "target": "libs-release-local/{1}",
                              "flat": "false",
                              "props": "${properties}",
                              "exclusions": [ "*.sha1", "*.md5"]
                            }
                         ]
                     }"""
                    def buildInfo = server.upload(uploadSpec)
                    buildInfo.env.collect()
                    server.publishBuildInfo(buildInfo)
                    echo '<--------------- Jar Publish Ended --------------->'
                }
            }
        }

    }
}
