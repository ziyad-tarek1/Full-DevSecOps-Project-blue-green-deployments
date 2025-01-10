#!/bin/bash

# Update all packages
sudo apt update -y

# Download the latest stable release of kubectl
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"

# Install kubectl
sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl

# Install bash-completion
sudo apt install -y bash-completion

# Enable kubectl bash completion
kubectl completion bash | sudo tee /etc/bash_completion.d/kubectl > /dev/null
sudo chmod a+r /etc/bash_completion.d/kubectl

# Add alias and enable completion in user's bashrc
echo 'alias k=kubectl' >> /home/ubuntu/.bashrc
echo 'complete -o default -F __start_kubectl k' >> /home/ubuntu.bashrc
echo 'source <(kubectl completion bash)' >> /home/ubuntu/.bashrc

# Source bash completion scripts
sudo chmod +x /usr/share/bash-completion/bash_completion
echo "source /usr/share/bash-completion/bash_completion" >> /home/ubuntu/.bashrc
source /home/ubuntu/.bashrc


######################################
#!/bin/bash
# Intsalling Java
sudo apt update -y
sudo apt install openjdk-17-jre -y
sudo apt install openjdk-17-jdk -y
java --version

# Installing Jenkins
curl -fsSL https://pkg.jenkins.io/debian/jenkins.io-2023.key | sudo tee \
  /usr/share/keyrings/jenkins-keyring.asc > /dev/null
echo deb [signed-by=/usr/share/keyrings/jenkins-keyring.asc] \
  https://pkg.jenkins.io/debian binary/ | sudo tee \
  /etc/apt/sources.list.d/jenkins.list > /dev/null
sudo apt update -y
sudo apt install jenkins -y

# Installing Docker 
#!/bin/bash
sudo apt update
sudo apt install docker.io -y
sudo usermod -aG docker jenkins
sudo usermod -aG docker ubuntu
sudo systemctl restart docker
sudo chmod 777 /var/run/docker.sock

# If you don't want to install Jenkins, you can create a container of Jenkins
# docker run -d -p 8080:8080 -p 50000:50000 --name jenkins-container jenkins/jenkins:lts

# Run Docker Container of Sonarqube
#!/bin/bash
#docker run -d  --name sonar -p 9000:9000 sonarqube:lts-community





# Installing Trivy
#!/bin/bash
sudo apt install wget apt-transport-https gnupg lsb-release -y
wget -qO - https://aquasecurity.github.io/trivy-repo/deb/public.key | sudo apt-key add -
echo deb https://aquasecurity.github.io/trivy-repo/deb $(lsb_release -sc) main | sudo tee -a /etc/apt/sources.list.d/trivy.list
sudo apt update
sudo apt install trivy -y




