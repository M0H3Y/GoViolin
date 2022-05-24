pipeline {
  agent any

  environment {
      
    IMAGE_NAME = "mohey/go-app:1.0.0-$BUILD_NUMBER"

  }
  
  stages {
      
    stage('Build The Docker Image') {
        
      steps {
        script {  
          echo "Building The Docker Image...."
          sh "docker build -t $IMAGE_NAME ."
        }
      }

      post {
        
        success {
          echo 'Building the docker image Succeeded.....'
          mail bcc: '', body: "Building the docker image Succeeded, You Can check the console output at $BUILD_URL", cc: '', from: '', replyTo: '', subject: "Successful Docker Image Build - $JOB_NAME", to: 'mohamedmohey67@gmail.com'
        }

        failure {
          echo 'Building the docker image failed.....'
          mail bcc: '', body: "Building the docker image failed, Please check the console output at $BUILD_URL", cc: '', from: '', replyTo: '', subject: 'Jenkins Build Docker Image Failure - $JOB_NAME', to: 'mohamedmohey67@gmail.com'
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
      post {
        
        success {
          echo 'Pushing the docker image Succeeded.....'
          mail bcc: '', body: "Pushing the docker image Succeeded, You Can check the console output at $BUILD_URL", cc: '', from: '', replyTo: '', subject: "Successful Docker Image Push - $JOB_NAME", to: 'mohamedmohey67@gmail.com'
        }

        failure {
          echo 'Pushing the docker image Failed.....'
          mail bcc: '', body: "Pushing the docker image failed, Please check the console output at $BUILD_URL", cc: '', from: '', replyTo: '', subject: 'Jenkins Push Docker Image Failed - $JOB_NAME', to: 'mohamedmohey67@gmail.com'
        }

      }

      
    }

    stage("Deploy To EKS") {

      environment {
        AWS_ACCESS_KEY_ID = credentials('jenkins_aws_access_key_id')
        AWS_SECRET_ACCESS_KEY = credentials('jenkins_aws_secret_access_key')
        
      }

      steps {
        script {
          echo 'Deploying app To EKS Cluster...'
          sh 'envsubst < kubernetes/deployment.yaml | kubectl apply -f - '
          sh 'kubectl apply -f kubernetes/nginx-ingress.yaml'
        }
      }
      
      post {
        
        success {
          echo 'Deploying app to EKS Cluster Succeeded'
          mail bcc: '', body: "Deploying app to EKS Cluster Succeeded,You Can check the console output at $BUILD_URL", cc: '', from: '', replyTo: '', subject: "Successful Deployment to EKS Cluster - $JOB_NAME", to: 'mohamedmohey67@gmail.com'
        }

        failure {
          echo 'Deploying app to EKS Cluster Failed'
          mail bcc: '', body: "Deploying app to EKS Cluster failed, Please check the console output at $BUILD_URL", cc: '', from: '', replyTo: '', subject: "Failed Deployment to EKS Cluster - $JOB_NAME", to: 'mohamedmohey67@gmail.com'
        }

      }

    }

  }
}

