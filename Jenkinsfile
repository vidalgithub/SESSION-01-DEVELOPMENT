


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
                        
                        choice(
                                    choices: ['No', 'Yes'], 
                                    name: 'deployUI'
                                 
                                ),
                        
                        choice(
                                    choices: ['Yes', 'No'], 
                                    name: 'deployDB'
                             
                                ),

                        choice(
                                    choices: ['Yes', 'No'], 
                                    name: 'deployREDIS'
                           
                                ),


                        choice(
                                    choices: ['Yes', 'No'], 
                                    name: 'deployAPPSERVER'
                    
                                ),




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


    
      

    stage('Login') {

			steps {
				sh 'echo $DOCKERHUB_CREDENTIALS_PSW | docker login -u $DOCKERHUB_CREDENTIALS_USR --password-stdin'
			}
		}


        
    stage('build appserver') {
      when{ 
          
          expression {
            env.deployAPPSERVER == 'Yes' }
          
            }
      
     steps {
         sh '''
         
        docker pull devopseasylearning2021/challenger:appserver
        docker tag devopseasylearning2021/challenger:appserver devopseasylearning2021/challenger-appserver:${BUILD_NUMBER}
    
                    '''
                }
            }
    
    
      stage('pushing appserver ') {
        when{ 
          
          expression {
            env.deployAPPSERVER == 'Yes' }
          
            }
      
     steps {
         sh '''
        docker push devopseasylearning2021/challenger-appserver:${BUILD_NUMBER}
    
                    '''
                }
            }



    stage('build yelb-db') {
      when{ 
          
          expression {
            env.deployDB == 'Yes' }
          
            }
      
     steps {
         sh '''
        cd  yelb-db
        docker build -t devopseasylearning2021/challenger-db:${BUILD_NUMBER} . 
        cd -
    
                    '''
                }
            }


       stage('pushing db ') {
         when{ 
          
          expression {
            env.deployDB == 'Yes' }
          
            }
      
     steps {
         sh '''
        docker push devopseasylearning2021/challenger-db:${BUILD_NUMBER}
    
                    '''
                }
            }




    //  stage('build yelb-ui') {
      // when{ 
          
      //     expression {
      //       env.deployUI == 'Yes' }
          
      //       }
      
    //  steps {
    //      sh '''
    //     cd  yelb-ui
    //     docker build -t devopseasylearning2021/challenger-ui:${BUILD_NUMBER} . 
    //     cd -
    
    //                 '''
    //             }
    //         }
       
    //   stage('pushing ui ') {
      // when{ 
          
      //     expression {
      //       env.deployUI == 'Yes' }
          
      //       }
      
    //  steps {
    //      sh '''
    //     docker push devopseasylearning2021/challenger-ui:${BUILD_NUMBER}
    
    //                 '''
    //             }
    //         }

     



     stage('build redis') {
       when{ 
          
          expression {
            env.deployREDIS == 'Yes' }
          
            }
      
     steps {
         sh '''
        cd  redis
        docker build -t devopseasylearning2021/challenger-redis:${BUILD_NUMBER} . 
        cd -
    
                    '''
                }
            }
       
 
    stage('pushing redis ') {
        when{ 
          
          expression {
            env.deployREDIS == 'Yes' }
          
            }
      
     steps {
         sh '''
        docker push devopseasylearning2021/challenger-redis:${BUILD_NUMBER}
    
                    '''
                }
            }


    
    stage('Update helm-charts') {

 steps {
     sh '''

rm -rf ./*   

rm -rf values_dev.yaml || true
cat <<EOF > values_dev.yaml
replicaCount: 1
tag:
    ui: ${BUILD_NUMBER}
    redis: ${BUILD_NUMBER}
    db: ${BUILD_NUMBER}
    appserver: ${BUILD_NUMBER}
EOF

 rm -rf SESSION-01-DEVELOPMENT || true 
docker run -i --rm -v $PWD:/dir -w /dir  devopseasylearning2021/s1-project02:maven-3.8.4-openjdk-8.5.1 bash -c " ls -l /root ; \
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
