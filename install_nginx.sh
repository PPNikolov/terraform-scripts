#!/bin/bash
sudo yum -y install epel-release
sudo yum -y install nginx
sudo systemctl start nginx
sudo systemctl enable nginx
cd /usr/share/nginx/html && sudo curl -XGET https://webstrg.s3-eu-west-1.amazonaws.com/index.html -O
