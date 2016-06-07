#!/bin/bash

# stop the pm2 instance gracefully
pm2 stop all 

# Clear the work folder
rm -rf /opt/node_home/*
