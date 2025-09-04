#On the VM to be used for the CI process, enter the following commands:

#1. create a dir and move into the dir
mkdir myagent && cd myagent

#2. download the agent, (please copy and paste the url from the "Download the agent" copy button)
sudo apt install wget -y  
wget https://vstsagentpackage.azureedge.net/agent/3.243.0/vsts-agent-linux-x64-3.243.0.tar.gz

#3. extract the download the agent files
tar zxvf vsts-agent-linux-x64-4.259.0.tar.gz
#4 configure the agent
./config.sh

#5. start the agent and keep it running
./run.sh
