#!/bin/bash

# stop the pm2 instance gracefully
su - ubuntu -c "pm2 stop all"
su - ubuntu -c "pm2 delete all"

# Clear the work folder
rm -rf /opt/node_home/*
