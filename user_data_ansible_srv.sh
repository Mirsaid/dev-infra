#!/bin/bash



# Update package repositories and install Ansible
sudo apt-get update -y
sudo apt-get install ansible -y

# Generate SSH key pair if it doesn't already exist
if [ ! -f ~/.ssh/id_rsa ]; then
    ssh-keygen -t rsa -N "" -f ~/.ssh/id_rsa
fi

# Clone the Ansible playbook repository
if [ ! -d ~/test ]; then
    git clone https://github.com/Mirsaid/ansible-zabbix_docker-deployment.git
else
    cd ~/test
fi

# Set permissions on the SSH private key
chmod 700 /home/ubuntu/.ssh
chmod 600 /home/ubuntu/.ssh/id_rsa
chmod 644 /home/ubuntu/.ssh/id_rsa.pub
