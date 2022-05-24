pipeline {
  agent any
  
  stages {
      
    stage('Build The Docker Image') {
        
      steps {
        script {  
          env.IMAGE_NAME = "mohey/go-app:1.0.0-$BUILD_NUMBER"
          echo "Building The Docker Image...."
          sh "docker build -t $IMAGE_NAME ."
        }
      }

      post {
           
        failure {
          echo 'Building the docker image failed.....'
          mail bcc: '', body: "Building the docker image failed, Please check the console output at $BUILD_URL", cc: '', from: '', replyTo: '', subject: 'Jenkins Build Failure', to: 'mohamedmohey67@gmail.com'
        }

      }

    }
    
    stage("Push Image To Dockerhub") {
      steps {
        script {
          withCredentials([usernamePassword(credentialsId: 'dockerhub_creds', usernameVariable: 'USER', passwordVariable: 'PASS')]) {
              
            sh '''
            echo $PASS | docker login -u $USER --password-stdin
            docker push $IMAGE_NAME
            '''
 
          }
        }
      }
      
    }


  }
}

