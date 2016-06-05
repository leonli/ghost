#!/bin/bash -v
su - ubuntu -c "curl -o- https://raw.githubusercontent.com/creationix/nvm/v0.31.1/install.sh | bash"
su - ubuntu -c "nvm install v4.4.4" 
su - ubuntu -c "npm install -g pm2"
su - ubuntu -c "mkdir /opt/node_home"
