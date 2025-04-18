Automating Skyebank-App Deployments: GitOps with ArgoCD, Terraform, SonarQube, Docker, and GitHub Actions

![image](https://github.com/user-attachments/assets/77d69f28-cf04-4322-9ee5-73e134f81e1b)


<img width="960" alt="2025-03-19 (39)" src="https://github.com/user-attachments/assets/7050d0b9-d37e-4a24-9b16-9cce398a37e8" />



**Step 1:**

1. clone the repository: Github repo: https://github.com/etaoko333/SkyeBank-Project.git
2. cd into EKS and create the cluster
3. terraform init
4. terraform plan
5. terraform apply
6. Once the EKS cluster is provisioned, configure kubectl to interact with the newly created cluster:
7. connect with your cluster with this code:
8. aws eks — region us-west-1 update-kubeconfig — name devopsola-cluster

**Step 2**: Integrating SonarQube for Code Quality
- Add SonarQube Configuration:
- Include a sonar-project.properties file in your repository:
- login to sonarqube server navigate to administration
- create project manually
- create your project and generate a code
- Open your GitHub and select your Repository
- In my case it is skyebank-app and Click on Settings and navigate to
- secret and click on environment
- paste the sonarque code
- Now go back to Your Sonarqube Dashboard
- Copy SONAR_TOKEN and click on Generate Token
- copy and paste on github environment
- Click on GenerateLet’s copy the Token and add it to GitHub secrets
- Now go back to GitHub and Paste the copied name for the secret and token
- Name: SONAR_TOKEN
- Secret: Paste Your Token and click on Add secret
- github environment for sonarqube
- Go to Sonarqube Dashboard and click on continue
- Now go back to the Sonarqube Dashboard
- Copy the Name and Value
- copy the script and run it on .github/workflows/deploy.yml
- Go back to the Sonarqube dashboard and copy the file name and content
- create .env file on the directory: paste code sonar.projectKey=skyebank-app
- Run SonarQube Analysis:
- The GitHub Actions workflow will automatically trigger the SonarQube analysis during the build process.

**Step 3: Configuring GitHub Actions for CI/CD**
-Create a GitHub Actions Workflow:
- Define a .github/workflows/deploy.yml file to automate the pipeline.
- Copy content and add it to the file

  name: Build,Analyze,scan
on:
  push:
    branches:
      - main
jobs:
  build-analyze-scan:
    name: Build
    runs-on: [self-hosted]
    steps:
      - name: Checkout code
        uses: actions/checkout@v2
        with:
          fetch-depth: 0  # Shallow clones should be disabled for a better relevancy of analysis
      - name: Build and analyze with SonarQube
        uses: sonarsource/sonarqube-scan-action@master
        env:
          SONAR_TOKEN: ${{ secrets.SONAR_TOKEN }}
          ```SONAR_HOST_URL: ${{ secrets.SONAR_HOST_URL }}


- the pipeline will trigger, after go to sonarqube homepage and check the result.

**Step 6: Add GitHub Runner**
-Go to GitHub and click on Settings –> Actions –> Runners
- set up runner on ubuntu
- login in to your instance and use the below commands to add a self-hosted runner
-ngitub actions pipeline connected
-Let’s start runner
-./run.sh
  -our runner is connected and listening for job

**Step 4: Building and Pushing Docker Images**
- Create a Personal Access token for your Dockerhub account
- Go to docker hub and click on your profile –> Account settings –> security –> New access token. Create a token and go back to github, click on settings and set up a new - environment. just like i did for sonarqube.

-full github actions pipeline .github/workflows/deploy.yml

```name: Skyebank-App CI/CD Pipeline
name: Build
on:
 push:
 branches:
 — main
jobs:
 build:
 name: Build
 runs-on: [self-hosted]
 steps:
 — uses: actions/checkout@v2
 with:
 fetch-depth: 0 # Shallow clones should be disabled for a better relevancy of analysis
 — uses: sonarsource/sonarqube-scan-action@master
 env:
 SONAR_TOKEN: ${{ secrets.SONAR_TOKEN }}
 SONAR_HOST_URL: ${{ secrets.SONAR_HOST_URL }}
- name: Log in to DockerHub
 uses: docker/login-action@v3
 with:
 username: ${{ secrets.DOCKERHUB_USERNAME }}
 password: ${{ secrets.DOCKERHUB_TOKEN }}
- name: Install Docker Scout
 run: |
 curl -fsSL https://raw.githubusercontent.com/docker/scout-cli/main/install.sh | sudo sh -s — -b /usr/local/bin
 echo “/usr/local/bin” >> $GITHUB_PATH
- name: Docker Scout Scan
 run: |
 docker-scout quickview fs://.
 docker-scout cves fs://.
- name: Docker Build and Push
 run: |
 sudo docker build -t sholly333/skyebank:latest .
 sudo docker push sholly333/skyebank:latest
 env:
 DOCKER_CLI_ACI: 1
- name: Docker Scout Image Scan
 run: |
 docker-scout quickview sholly333/skyebank:latest
 docker-scout cves sholly333/skyebank:latest
deploy:
 needs: build
 runs-on: self-hosted

steps:
 — name: Docker Pull Image
 run: sudo docker pull sholly333/skyebank:latest
- name: Deploy to Container
 run: sudo docker run -d — name skyebank-app -p 3000:80 sholly333/skyebank:latest
- name: Configure AWS Credentials
 env:
 AWS_ACCESS_KEY_ID: ${{ secrets.AWS_ACCESS_KEY_ID }}
 AWS_SECRET_ACCESS_KEY: ${{ secrets.AWS_SECRET_ACCESS_KEY }}
 AWS_REGION: us-west-1
 ```run: echo “AWS credentials configured”`
  
**Step 3: Configure argocd**
- lets generate a password for argocd deployment.
- connect into your instance
- paste this code on your terminal to connect with your cluster: aws eks — region us-west-1 update-kubeconfig — name devopsola-cluster

**Step 4: ARGO CD SETUP**
- configure install ArgoCD
- ARGOCD INSTALLATION LINK
- You will redirected to this page
- kubectl create namespace argocd

-kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/v2.4.7/manifests/install.yaml
-
COMMANDS ARGOCD
- By default, argocd-server is not publicly exposed. For this project, we will use a Load Balancer to make it usable:
- kubectl patch svc argocd-server -n argocd -p '{"spec": {"type": "LoadBalancer"}}'
- One load balancer will created in the AWS
-sudo apt install jq -y
-export ARGOCD_SERVER=`kubectl get svc argocd-server -n argocd -o json | jq --raw-output '.status.loadBalancer.ingress[0].hostname

-when you run this command, it will export the hostname of the ArgoCD server’s load - ---- balancer and store it in the ARGOCD_SERVER environment variable, which you can then use in other commands or scripts to interact with the ArgoCD server. This can be useful when you need to access the ArgoCD web UI or interact with the server programmatically.
- If run this command you will get the load balancer external IP
- echo $ARGOCD_SERVER
- Login
-The command you provided is used to extract the password for the initial admin user of ArgoCD, decode it from base64 encoding, and store it in an environment variable named
  -ARGO_PWD.
- export ARGO_PWD=`kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d`
- If you want to see your password provide the below command
-echo $ARGO_PWD`
- Now copy the load balancer IP and paste it into the browser
-echo $ARGOCD_SERVER`
- Now you will see this page. if you get an error click on advanced and click on proceed.
- Now you will see this page and log in to ArgoCD
- For the password, you have to provide the below command and copy it
`echo $ARGO_PWD`


<img width="960" alt="2025-03-16 (12)" src="https://github.com/user-attachments/assets/41cdc7d9-1a83-403d-b39b-4707db6c4dc6" />


- Click on Sign in and you will see this page
- Click on Repositories
- Now click on Connect Repo Using HTTPS
- Add Github details, Type as git, Project as default and provide the GitHub URL of this manifest and click on connect
- Click on Manage Your application
- You will see this page and click on New App
- Now provide the following details as in the image
- Application name
- kubernetes pasth
- click on create
  

<img width="960" alt="2025-03-19 (9)" src="https://github.com/user-attachments/assets/20fa3b26-e549-4de5-96ce-6c2ef41a91dc" />


- sync successfull
-run this command to get the loadbalancer for the deployment.
- kubectl get svc -n skyebank
- copy the balance and paste into your browser.
- your app is up and running

<img width="960" alt="2025-03-19 (6)" src="https://github.com/user-attachments/assets/1049ad2c-807d-4262-8f6e-00ccc7ecc13a" />




Conclusion
By following this guide, you’ve successfully automated the deployment of the Skyebank-App using a GitOps approach. Leveraging tools like Terraform, GitHub Actions, SonarQube, Docker, and ArgoCD ensures that your deployments are secure, efficient, and reliable. This setup not only reduces manual intervention but also improves the overall quality and security of your application.

Feel free to adapt this guide to your specific use case and explore further optimizations. Happy deploying! 🚀

linkedin: https://www.linkedin.com/in/osenat-alonge-84379124b?lipi=urn%3Ali%3Apage%3Ad_flagship3_profile_view_base_contact_details%3BvRrFHll9S5a7axIZDqFu2A%3D%3D
