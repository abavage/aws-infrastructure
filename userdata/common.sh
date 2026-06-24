#!/bin/bash
dnf -y install sysstat httpd firewalld

systemctl enable --now firewalld

firewall-cmd --permanent --add-service=http
firewall-cmd --reload

echo "this hostname: $(hostnane)" > /var/www/html/index.html