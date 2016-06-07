#!/bin/bash
rm -rf /tmp/*
cd /opt/node_home
npm install && \ 
grunt init --force && \
grunt prod

