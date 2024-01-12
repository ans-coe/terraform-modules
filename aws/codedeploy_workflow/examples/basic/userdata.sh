#!/bin/bash
cd /home/ec2-user/
yum install ruby -y
wget https://aws-codedeploy-eu-west-1.s3.eu-west-1.amazonaws.com/latest/install
chmod +x ./install
./install auto