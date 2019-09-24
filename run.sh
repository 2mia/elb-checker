#!/bin/bash

sudo docker kill hi
sudo docker run \
  --log-driver syslog \
  --rm -d -p 80:9292 -v `pwd`:/app --name hi elb-checker

   #--log-driver local --log-opt max-size=10m \
