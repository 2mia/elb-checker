#!/bin/bash

sudo docker kill hi
sudo docker run --rm -d -p 80:9292 -v `pwd`:/app --name hi elb-checker
