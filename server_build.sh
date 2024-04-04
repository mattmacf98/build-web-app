#!/bin/bash

sudo yum update -y
sudo yum install git -y
sudo yum install cmake -y
sudo yum install tree -y
sudo yum install vim -y
sudo yum install tmux -y
sudo yum install make automake gcc gcc-c++ kernel-devel -y

sudo yum install -y https://download.postgresql.org/pub/repos/yum/10/redhat/rhel-7-x86_64/pgdg-centos10-10-2.noarch.rpm
sudo yum install -y postgresql10-server postgresql10-devel
sudo yum install -y epel-release


sudo yum install -y docker
sudo systemctl start docker
sudo usermod -aG docker ec2-user

sudo curl -L "https://github.com/docker/compose/releases/download/1.29.2/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose

echo "FINISHED" > home/ec2-user/output.txt
