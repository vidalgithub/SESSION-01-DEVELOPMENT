pipeline {
agent { 
    label 'node2' 
    }

options {
    buildDiscarder(logRotator(numToKeepStr: '20'))
    disableConcurrentBuilds()
    timeout (time: 30, unit: 'MINUTES')
    timestamps()
  }
   
    stages {

        stage('Setup parameters') {
            steps {
                script {
                    properties([
                        parameters([
                             string(name: 'WARNTIME',
                             defaultValue: '2',
                            description: '''Warning time (in minutes) before starting upgrade'''),
                         
                          string(
                                defaultValue: 'develop',
                                name: 'Please_leave_this_section_as_it_is',
                                trim: true
                            ),
                        ])
                    ])
                }
            }
        }
 
    //////////////////////////////////
       stage('warning') {
      steps {
        script {
            notifyUpgrade(currentBuild.currentResult, "WARNING")
            sleep(time:env.WARNTIME, unit:"MINUTES")
        }
      }
    }

        
        
      stage('Maven works') {
              agent {
                docker {
                  label 'node2'  // both label and image
                  image 'devopseasylearning2021/s1-project02:maven-3.8.4-openjdk-8'
                }
              }
            steps {
                sh '''
                mvn clean
                mvn validate 
                mvn compile
                mvn test
                mvn package 
                mvn verify 
                mvn install
                rm -rf $WORKSPACE/webapp.war || true 
                cp -r webapp/target/webapp.war .
                ls -l 
                pwd 
                '''
            }
        }



        stage('SonarQube analysis') {
            agent {
                docker {
                  label 'node2'  // both label and image
                  image 'sonarsource/sonar-scanner-cli:4.7.0'
                }
               }
               environment {
        CI = 'true'
        //  scannerHome = tool 'Sonar'
        scannerHome='/opt/sonar-scanner'
    }
            steps{
                withSonarQubeEnv('Sonar') {
                    sh "${scannerHome}/bin/sonar-scanner"
                }
            }
        }


    
      
       stage('build images') {
        agent { 
    label 'node2' 
    }
            steps {
                sh '''

cd  $WORKSPACE
rm -rf Dockerfile || true 
cat <<EOF > Dockerfile
FROM tomcat:8.0-alpine
COPY ./webapp.war  /usr/local/tomcat/webapps
EOF

                docker build -t devopseasylearning2021/challenger:${BUILD_NUMBER} .
                docker images 

                '''
            }
        }

stage('pushing image to dockerhub') {
    agent { 
    label 'node2' 
    }
 steps {
     sh '''

cat /home/ansible/password.txt | docker login --username devopseasylearning2021 --password-stdin
docker push devopseasylearning2021/challenger:${BUILD_NUMBER}

                '''
            }
        }


stage('generate compose file ') {
    agent { 
    label 'node2' 
    }
 steps {
     sh '''

docker rm -f challenger
rm -rf docker-compose.yml || true 
cat <<EOF > docker-compose.yml
version : "3.3"
services:
  challenger:
       image: devopseasylearning2021/challenger:${BUILD_NUMBER}
       expose:
        - 8080
       container_name: challenger
       restart: always

       ports: 
        - 5050:8080

EOF

ls -l
                '''
            }
        }







    }


post {
    always {
      script {
        notifyUpgrade(currentBuild.currentResult, "POST")
      }
    }
    cleanup {
      deleteDir()
    }
  }



}






def notifyUpgrade(String buildResult, String whereAt) {
  if (Please_leave_this_section_as_it_is == 'origin/develop') {
    channel = 'jenkins'
  } else {
    channel = 'jenkins'
  }
  if (buildResult == "SUCCESS") {
    switch(whereAt) {
      case 'WARNING':
        slackSend(channel: channel,
                color: "#439FE0",
                message: "Challenger: Upgrade starting in ${env.WARNTIME} minutes @ ${env.BUILD_URL}  Application CHALLENGER")
        break
    case 'STARTING':
      slackSend(channel: channel,
                color: "good",
                message: "Challenger: Starting upgrade @ ${env.BUILD_URL} Application CHALLENGER")
      break
    default:
        slackSend(channel: channel,
                color: "good",
                message: "Challenger: Upgrade completed successfully @ ${env.BUILD_URL}  Application CHALLENGER")
        break
    }
  } else {
    slackSend(channel: channel,
              color: "danger",
              message: "Challenger: Upgrade was not successful. Please investigate it immediately.  @ ${env.BUILD_URL}  Application CHALLENGER")
  }
}

