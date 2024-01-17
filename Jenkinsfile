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
def imageName = 'yogip92.jfrog.io/yogi-docker-local/ttrend'
def version   = '2.1.2'

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

        // stage('SonarQube analysis') {
        //     environment {
        //         scannerHome = tool 'yogip92-sonar-scanner'
        //         nodejsHome = tool 'Node.js' // Add this line to reference Node.js installation
        //     }
        //     steps {
        //         script {
        //             // Add Node.js to PATH
        //             env.PATH = "${nodejsHome}/bin:${env.PATH}"
        //
        //             withSonarQubeEnv('yogip92-sonarqube-server') {
        //                 sh "${scannerHome}/bin/sonar-scanner -X"
        //             }
        //         }
        //     }
        // }

        // stage("Quality Gate") {
        //     steps {
        //         script {
        //             timeout(time: 1, unit: 'HOURS') {
        //                 def qg = waitForQualityGate()
        //                 if (qg.status != 'OK') {
        //                     error "Pipeline aborted due to quality gate failure: ${qg.status}"
        //                 }
        //             }
        //         }
        //     }
        // }

        stage("Jar Publish") {
    steps {
        script {
            echo '<--------------- Jar Publish Started --------------->'
            def server = Artifactory.newServer url: registry + "/artifactory/", credentialsId: "artifactory-cred"
            def properties = "buildid=${env.BUILD_ID},commitid=${GIT_COMMIT}"
            def uploadSpec = """{
                  "files": [
                    {
                      "pattern": "jarstaging/(*)",
                      "target": "yogi-libs-release-local/{1}",
                      "flat": "false",
                      "props": "${properties}",
                      "exclusions": [ "*.sha1", "*.md5"]
                    }
                 ]
             }"""
            try {
                def buildInfo = server.upload(uploadSpec)
                buildInfo.env.collect()
                server.publishBuildInfo(buildInfo)
                echo '<--------------- Jar Publish Ended --------------->'
            } catch (Exception e) {
                echo "Error uploading artifacts to Artifactory: ${e.message}"
                error "Failed to publish artifacts to Artifactory"
                currentBuild.result = 'FAILURE' // Mark the build as failed
                // Add more logging if needed
                throw e // Rethrow the exception to get more details in the Jenkins logs
            }
        }
    }
}
        stage(" Docker Build ") {
          steps {
            script {
               echo '<--------------- Docker Build Started --------------->'
               app = docker.build(imageName+":"+version)
               echo '<--------------- Docker Build Ends --------------->'
            }
          }
        }

                stage (" Docker Publish "){
            steps {
                script {
                   echo '<--------------- Docker Publish Started --------------->'  
                    docker.withRegistry(registry, 'artifactory-cred'){
                        app.push()
                    }    
                   echo '<--------------- Docker Publish Ended --------------->'  
                }
            }
        }

    }
}
