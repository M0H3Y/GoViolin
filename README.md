# Content
1. [GoViolin Features](#govioling)
2. [Run the app using Docker](#docker)
3. [Deploy the app to EKS Cluster](#eks)
4. [Create The Pipeline](#pipeline)
5. [Configure Email Notification in Jenkins](#email_notification)
6. [Run the Pipeline](#run)
7. [Emails](#email)

<a name="govioling"></a>
# GoViolin


GoViolin is a web app written in Go that helps with violin practice.

Currently hosted on Heroku at https://go-violin.herokuapp.com/

GoViolin allows practice over both 1 and 2 octaves.

Contains:
* Major Scales
* Harmonic and Melodic Minor scales
* Arpeggios
* A set of two part scale duet melodies by Franz Wohlfahrt

<a name="docker"></a>
# Run the app using Docker

To run the application using docker execute the following commands: 

```
docker build -t go-app:1.0.
```
```
docker run -d -p 8080:8080 go-app:1.0
```

![Running the app using docker](/images/docker_1.png)

<a name="eks"></a>
# Deploy the app to EKS Cluster

First, you need to have an aws account and have [kubectl](https://kubernetes.io/docs/tasks/tools/install-kubectl-linux/) and [eksctl](https://docs.aws.amazon.com/eks/latest/userguide/eksctl.html)  installed on your machine. 

To create an eks cluster run the following command : 

```
eksctl create cluster  
--name go-app-cluster 
--region eu-west-3  
--nodegroup-name go-app-nodes --node-type t2.small 
--nodes 2 --nodes-min 1 
--nodes-max 3
```



Then to update the kubeconfig file run the follwing command : 

```
aws eks update-kubeconfig --name go-app-cluster
```

Then you need to push the image you built to a public or private repo (I'll use dockerhub for this project).

```
docker tag <old_image_name> <dockerhub_user>/<repo-name>:<tag>

docker login -u your_user_name

docker push <dockerhub_user>/<repo-name>:<tag>
```

Before deploying the app you need to set the **IMAGE_NAME** Environment variable to the name of the image you built. 
 
```
export IMAGE_NAME=<dockerhub_user/<repo_name>:<tag\>
```

As i'm using a private repo i need to provide the kuberenets cluster with docker hub creds to be able to pull the image. 

```
kubectl create secret docker-registry dockerhub-creds --docker-username=<user_name> --docker-password=<Your_password>
```

You need to deploy nginx ingress controller on your eks cluster as i'm using nginx ingress to expose the application to the internet. 

```
kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/controller-v1.2.0/deploy/static/provider/aws/deploy.yaml
```
 
 And finally to deploy the app run the following commands : 
 
```
envsubst < kubernetes/deployment.yaml | kubectl apply -f -

kubectl apply -f kubernetes/nginx-ingress.yaml
```

![Get The App Url](/images/ingress_1.png)
![Running the App on eks](/images/ingress_2.png)

<a name="pipeline"></a>
# Create The Pipeline 

1- Create a new item in jenkins
 
2- Create a Pipeline Job 
 
![](/images/jenkins_1.png)
 
3- Choose Pipeline from script SCM and add your repo url and the github credentials.

![](/images/jenkins_2.png)

4- From Jenkins Dashboard go to manage jenkins then manage Credentials and add your docker hub credentials and aws credentials as i'll be using it for deploying the app on eks cluster.

![](/images/jenkins_3.png)

5- Install kubectl and aws-iam-authenticator inside jenkins container

```bash
curl -LO https://storage.googleapis.com/kubernetes-release/release/v1.23.6/bin/linux/amd64/kubectl
chmod +x kubectl  
mv kubectl /usr/local/bin
```
```bash
curl -o aws-iam-authenticator https://amazon-eks.s3.us-west-2.amazonaws.com/1.21.2/2021-07-05/bin/linux/amd64/aws-iam-authenticator  
chmod +x ./aws-iam-authenticator  
mv /aws-iam-authenticator /usr/local/bin
```


After provisionng the EKS Cluster you need to give jenkins the permissions to deploy applications on your eks cluster, for simplicity i'll be using the credentials of the user who created cluster. 

create the following kubeconfig file at ~/.kube/config and replace the api endpoint url, ca-cert and cluster name with your cluster data. 

```
apiVersion: v1  
clusters:  
- cluster:  
server: <endpoint_url>  
certificate-authority-data: <base64-encoded-ca-cert>  
name: kubernetes  
contexts:  
- context:  
cluster: kubernetes  
user: aws  
name: aws  
current-context: aws  
kind: Config  
preferences: {}  
users:  
- name: aws  
user:  
exec:  
apiVersion: client.authentication.k8s.io/v1alpha1  
command: aws-iam-authenticator  
args:  
- "token"  
- "-i"  
- "<cluster_name>"
```

<a name="email_notification"></a>
# Configure Email Notification in Jenkins

From jenkins dashboard go to manage jenkins then configure system and then Enter the SMTP server name under Email Notification.

Click the Advanced button and then click the checkbox next to the Use SMTP Authentication option and enter your email and password.

![](/images/jenkins_4.png)

<a name="run"></a>
# Run the Pipeline 
![](/images/pipeline.png)
![](/images/eks_2.png)
![](/images/eks_1.png)

<a name="email"></a>
# Emails
![](/images/email_3.png)![](/images/email_2.png)![](/images/email_1.png)




