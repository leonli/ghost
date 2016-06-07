#!/bin/bash -v
apt-get -y update
curl -sL https://deb.nodesource.com/setup_4.x | sudo -E bash -
apt-get install -y nodejs
npm install -g pm2
mkdir /opt/node_home
chown ubuntu:ubuntu /opt/node_home

# install code deploy agent
apt-get -y install python-pip
apt-get -y install ruby2.0
apt-get -y install wget
cd /home/ubuntu
wget https://aws-codedeploy-us-west-2.s3.amazonaws.com/latest/install
chmod +x ./install
./install auto

# install git
apt-get install -y git

# install the AWS cli
pip install awscli

# instal grunt
npm install -g grunt-cli
