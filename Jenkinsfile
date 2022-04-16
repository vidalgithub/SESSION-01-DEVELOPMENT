pipeline {
agent { 
    label 'node1' 
    }

options {
    buildDiscarder(logRotator(numToKeepStr: '20'))
    disableConcurrentBuilds()
    timeout (time: 30, unit: 'MINUTES')
    timestamps()
  }
   
    stages {


        stage('Maven clean validate ') {
              agent {
                 docker { image 'devopseasylearning2021/s1-project02:maven-3.8.4-openjdk-8' }
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
            agent{
                docker { image 'sonarsource/sonar-scanner-cli:4.7.0' }  
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


        stage("Quality Gate"){

         steps {
                waitForQualityGate abortPipeline: true
            }
      }
      
      
       stage('build images') {
            steps {
                sh '''

cd  ~/home/ansible/home/ansible/workspace/SESSION01/PIPELINE-02/DEVELOPMENT/Branch-deployment-test@2
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
 steps {
     sh '''

cat /home/ansible/password.txt | docker login --username devopseasylearning2021 --password-stdin
docker push devopseasylearning2021/challenger:${BUILD_NUMBER}

                '''
            }
        }


stage('generate compose file ') {
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





}



    
 
