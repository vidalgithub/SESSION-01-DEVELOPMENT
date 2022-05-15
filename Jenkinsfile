pipeline {
    agent any

    environment {
		DOCKERHUB_CREDENTIALS=credentials('dockerhub')
	}

    options { buildDiscarder(logRotator(artifactDaysToKeepStr: '',
     artifactNumToKeepStr: '', daysToKeepStr: '3', numToKeepStr: '5'))
      disableConcurrentBuilds() }
      
      
    stages {
     
     


     stage('Build images') {
            steps {
                sh '''
                docker build -t eric:001 .
                
                '''
            }
        }


     stage('Tag image ') {
            steps {
               sh '''
              docker tag eric:001  devopseasylearning2021/eric:001 
                '''
            }
        }



      stage('Docker Login') {

			steps {
				sh 'echo $DOCKERHUB_CREDENTIALS_PSW | docker login -u $DOCKERHUB_CREDENTIALS_USR --password-stdin'
			}
		}

           
            

     stage('Docker push ') {
            steps {
               sh '''
              docker push devopseasylearning2021/eric:001 
                '''
            }
        }




    }






}
