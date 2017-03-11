#!/bin/bash
set -e

# Update the package index
apt-get update

# Additional useful software
apt-get -y install mc htop vim git

# Install packages to allow apt to use a repository over HTTPS
apt-get -y install apt-transport-https ca-certificates curl software-properties-common

# Add Docker’s official GPG key
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -

# To add the repository
add-apt-repository \
   "deb [arch=amd64] https://download.docker.com/linux/ubuntu \
   $(lsb_release -cs) \
   stable"

# Update the package index again
apt-get update

# Install the latest version of Docker
apt-get -y install docker-ce

# Create the group by Docker
groupadd docker

# The 'ubuntu' is default user in the image in own cloud
usermod -aG docker ubuntu

# Start Docker on boot
systemctl enable docker

# Install Docker Compose
curl -L https://github.com/docker/compose/releases/download/1.11.2/docker-compose-`uname -s`-`uname -m` > /usr/local/bin/docker-compose
chmod +x /usr/local/bin/docker-compose
