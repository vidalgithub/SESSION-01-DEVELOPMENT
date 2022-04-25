


pipeline {
agent { 
    label 'deploy-main' 
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
                  label 'deploy-main'  // both label and image
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
                  label 'deploy-main'  // both label and image
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
    label 'deploy-main' 
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
    label 'deploy-main' 
    }
 steps {
     sh '''

cat /home/ansible/password.txt | docker login --username devopseasylearning2021 --password-stdin
docker push devopseasylearning2021/challenger:${BUILD_NUMBER}

                '''
            }
        }










stage('Update helm-charts') {
    agent { 
    label 'deploy-main' 
    }
 steps {
     sh '''
rm -rf SESSION01-PROJECT02-CHARTS || true 
git clone git@github.com:devopseasylearning/SESSION01-PROJECT02-CHARTS.git
cd SESSION01-PROJECT02-CHARTS/pipeline02-dev
git pull --all 

cat <<EOF > values-dev.yaml
replicaCount: 1
image:
  repository: devopseasylearning2021
  pullPolicy: Always
  tag: ${BUILD_NUMBER}
service:
  type: LoadBalancer
  port: 80
EOF

cat values-dev.yaml
git status 

git add -A
git config --global user.email "info@devopseasylearning.com"
git config --global user.name "ansible"
git commit -m "Update from jenkins on build ${BUILD_NUMBER}"
git push 

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
    channel = 'session2-november-2021'
  } else {
    channel = 'session2-november-2021'
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

    
      
      
      
      
     
     
      
      
     
      
      
      
      
      
      
      

      
      
      
      
      
      
      
      
       
