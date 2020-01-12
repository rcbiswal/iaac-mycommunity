#! /bin/bash
yum update -y
yum install httpd -y
service httpd start
chkconfig httpd on
yum install git -y
git clone https://github.com/rcbiswal/mycommunity-project.git
cp -p ./mycommunity-project/* /var/www/html/