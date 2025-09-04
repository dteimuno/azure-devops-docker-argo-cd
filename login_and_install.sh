az login
#Create resource group in East US2
az group create -l eastus2 -n dtmgroup
#Set variables
vmname="dtmvm"
username="azureuser"
resourcegroup="dtmgroup"
region="eastus2"
#Get VM images 
az vm image list --all
#Or with respect to Azure region
az vm image list -l $region
#Copy the URN for the image you want to use
#Set image as variable
image="Canonical:ubuntu-24_04-lts:server:latest"
#Create VM in Azure portal for speed. The CLI can also be used
#Make SSH key readable:
sudo chmod 400 <private_key_file>
#SSH into VM
ssh azureuser@<vm-ip-address-public>
#Update the VM
sudo apt-get update
#Install docker and docker compose
#### 1. Install required packages
sudo apt-get install \
  ca-certificates \
  curl \
  gnupg \
  lsb-release

#### 2. Add Docker Official GPG Key
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg

#### 3. Set Up the Stable Repository
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu \
  $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

#### 4. Install Docker Engine
sudo apt-get update
sudo apt-get install docker-ce docker-ce-cli containerd.io -y

#### 5. Install Docker Compose
sudo curl -L "https://github.com/docker/compose/releases/download/$(curl -s https://api.github.com/repos/docker/compose/releases/latest | grep -oP '"tag_name": "\K(.*)(?=")')/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose

#### 6. Manage Docker as a Non-Root User and refresh it
sudo usermod -aG docker $USER
newgrp docker

#### 7. Check versions
sudo docker --version
docker-compose --version

#### 8. Check you can docker command without sudo
docker ps

#Clone repo for this project:
git clone https://github.com/dockersamples/example-voting-app.git

#Chaneg directory into directory for this project
cd example-voting-app

#Create containers from docker compose files:
docker-compose up -d

#Check status of containers
docker ps

#Open up port 8080 and 8081 on VM so we can test on a web browser our voting app:
az vm open-port -g dtmgroup -n dtmvm --port 8080
az vm open-port -g dtmgroup -n dtmvm --port 8081 --priority 901
