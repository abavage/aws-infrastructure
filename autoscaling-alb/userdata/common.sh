#!/bin/bash
dnf -y install sysstat httpd firewalld

systemctl enable --now firewalld

firewall-cmd --permanent --add-service=http
firewall-cmd --reload

systemctl enable --now httpd

dnf install -y https://s3.amazonaws.com/ec2-downloads-windows/SSMAgent/latest/linux_amd64/amazon-ssm-agent.rpm
systemctl enable --now amazon-ssm-agent


TOKEN=$(curl -s -X PUT "http://169.254.169.254/latest/api/token" -H "X-aws-ec2-metadata-token-ttl-seconds: 300")
AZ=$(curl -s -H "X-aws-ec2-metadata-token: $TOKEN" http://169.254.169.254/latest/meta-data/placement/availability-zone)
REGION=$(curl -s -H "X-aws-ec2-metadata-token: $TOKEN" http://169.254.169.254/latest/meta-data/placement/region)
HW=$(hostnamectl  | grep "Hardware Model" | awk -F: '{print $2}' | sed 's/ //g')
echo "<h1>This is hostname: $(hostname) in $AZ, $HW </h1>" > /var/www/html/index.html