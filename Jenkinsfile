


pipeline {
agent any

options {
    buildDiscarder(logRotator(numToKeepStr: '20'))
    disableConcurrentBuilds()
    timeout (time: 60, unit: 'MINUTES')
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
                  image 'devopseasylearning2021/s1-project02:maven-3.8.4-openjdk-8.5'
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
                docker run -i --rm -v $PWD:/dir -w /dir  devopseasylearning2021/s1-project02:maven-3.8.4-openjdk-8.4.4 bash -c " ls -l /root ; \
		cp -r /root/* /dir ; \
		rm -rf SESSION-01-DEVELOPMENT || true ; \
		bash clone.sh ; \
		rm -rf push.sh clone.sh"
                ls -l 
                
                cd SESSION-01-DEVELOPMENT 
               
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

 steps {
     sh '''
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


docker run -i --rm -v $PWD:/dir -w /dir  devopseasylearning2021/s1-project02:maven-3.8.4-openjdk-8.4.4 bash -c " ls -l /root ; \
		cp -r /root/*  /dir ; \
		bash helm.sh"
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

    
      
      
      
      
     
     
      
      
     
      
      
      
      
      
      
      

      
      
      
      
      
      
      
      
       
