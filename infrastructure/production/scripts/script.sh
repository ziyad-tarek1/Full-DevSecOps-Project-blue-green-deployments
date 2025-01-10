#!/bin/bash
# For Ubuntu 22.04
# Intsalling Java


sudo apt update -y
sudo apt upgrade -y
sudo apt update && sudo apt upgrade -y
sudo do-release-upgrade

sudo apt install -y openjdk-11-jdk
java -version
wget http://ftp.debian.org/debian/pool/main/i/init-system-helpers/init-system-helpers_1.60_all.deb

sudo dpkg -i init-system-helpers_1.60_all.deb

curl -fsSL https://pkg.jenkins.io/debian-stable/jenkins.io-2023.key | sudo tee \
  /usr/share/keyrings/jenkins-keyring.asc > /dev/null

echo deb [signed-by=/usr/share/keyrings/jenkins-keyring.asc] \
  https://pkg.jenkins.io/debian-stable binary/ | sudo tee \
  /etc/apt/sources.list.d/jenkins.list > /dev/null


sudo apt install -y jenkins


####################################
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
sudo apt-get update -y
sudo apt-get install jenkins -y

# Installing Docker 
#!/bin/bash
sudo apt update
sudo apt install docker.io -y
sudo usermod -aG docker jenkins
sudo usermod -aG docker ubuntu
sudo systemctl restart docker
sudo chmod 777 /var/run/docker.sock



# Run Docker Container of Sonarqube
docker run -d  --name sonar -p 9000:9000 sonarqube:lts-community


# Installing AWS CLI
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
sudo apt install unzip -y
unzip awscliv2.zip
sudo ./aws/install

# Installing Kubectl
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


# Installing Trivy
sudo apt-get install wget apt-transport-https gnupg lsb-release -y
wget -qO - https://aquasecurity.github.io/trivy-repo/deb/public.key | sudo apt-key add -
echo deb https://aquasecurity.github.io/trivy-repo/deb $(lsb_release -sc) main | sudo tee -a /etc/apt/sources.list.d/trivy.list
sudo apt update
sudo apt install trivy -y


