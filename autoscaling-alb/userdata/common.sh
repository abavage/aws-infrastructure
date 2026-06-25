#!/bin/bash
dnf -y install sysstat httpd firewalld

systemctl enable --now firewalld

firewall-cmd --permanent --add-service=http
firewall-cmd --reload

systemctl enable --now httpd

dnf install -y https://s3.amazonaws.com/ec2-downloads-windows/SSMAgent/latest/linux_amd64/amazon-ssm-agent.rpm
systemctl enable --now amazon-ssm-agent

echo "this hostname: $(hostname)" > /var/www/html/index.html