#!/bin/bash
yum update
yum install httpd -y
systemctl start httpd
systemctl enable httpd
cat <<EOF > /var/www/html/index.html
"welcome to amazon linux server"
     EOF