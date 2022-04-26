


pipeline {
agent any

options {
    buildDiscarder(logRotator(numToKeepStr: '20'))
    disableConcurrentBuilds()
    timeout (time: 30, unit: 'MINUTES')
    timestamps()
  }

  environment {
		DOCKERHUB_CREDENTIALS=credentials('dockerhub')
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
                  image 'devopseasylearning2021/s1-project02:maven-3.8.4-openjdk-8.3'
	          args '-u 0:0'
                }
              }
            steps {
                sh '''
		rm -rf $WORKSPACE/webapp.war || true 
                mvn clean
                mvn validate 
                mvn compile
                mvn test
                mvn package 
                mvn verify 
                mvn install
                
             
                rm -rf SESSION-01-DEVELOPMENT || true
		id
		whoami
                cp -r /root/push.sh . || true 
		
		bash push.sh 
                '''
            }
        }



        stage('SonarQube analysis') {
            agent {
                docker {
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

            steps {
                sh '''
                rm -rf SESSION-01-DEVELOPMENT || true
                git clone git@github.com:devopseasylearning/SESSION-01-DEVELOPMENT.git
                cd SESSION-01-DEVELOPMENT 
                git pull --all
                docker build -t devopseasylearning2021/challenger:${BUILD_NUMBER} .
                docker images 

                '''
            }
        }


		stage('Login') {

			steps {
				sh 'echo $DOCKERHUB_CREDENTIALS_PSW | docker login -u $DOCKERHUB_CREDENTIALS_USR --password-stdin'
			}
		}

		stage('Push') {

			steps {
				sh 'docker push devopseasylearning2021/challenger:${BUILD_NUMBER}'
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
  port: 8080
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
    channel = 'development-alerts'
  } else {
    channel = 'development-alerts'
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

    
      
      
      
      
     
     
      
      
     
      
      
      
      
      
      
      

      
      
      
      
      
      
      
      
       
