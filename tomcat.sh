#!/bin/bash
# //----------------------------------------------------------------------------
# // tomcat.sh
# //----------------------------------------------------------------------------
# // tomcat installation script
# //----------------------------------------------------------------------------
# // Gareth Jones - gareth@gareth.com
# //----------------------------------------------------------------------------

# https://www.tecmint.com/install-apache-tomcat-on-debian-10/

# update and upgrade
apt update
apt -y upgrade

# install required components
apt -y install sudo curl wget default-jdk

# allow wheel users to SUDO
echo "%wheel ALL=(ALL) ALL" | (EDITOR="tee -a" visudo)

# create user for tomcat service
mkdir /opt/tomcat
groupadd tomcat
useradd -s /bin/false -g tomcat -d /opt/tomcat tomcat

# download tomcat and expand
curl -O https://httpd-mirror.sergal.org/apache/tomcat/tomcat-9/v9.0.45/bin/apache-tomcat-9.0.45.tar.gz
sudo tar xzvf apache-tomcat-9*tar.gz -C /opt/tomcat --strip-components=1

# set permissions for the tomcat installation directory
cd /opt/tomcat
chgrp -R tomcat /opt/tomcat
chmod -R g+r conf
chmod g+x conf
chown -R tomcat webapps/ work/ temp/ logs/

# this command displays the JAVA_HOME
update-java-alternatives -l

# creatre a tomcat systemd service file
# wget /etc/systemd/system/tomcat.service

systemctl daemon-reload
systemctl start tomcat
systemctl status tomcat
systemctl enable tomcat

# sudo nano /opt/tomcat/conf/tomcat-users.xml
#####
# <role rolename="admin-gui,manager-gui"/> 
# <user username="admin" password="password" roles="admin-gui,manager-gui"/>
#####

# sudo nano /opt/tomcat/webapps/manager/META-INF/context.xml
# sudo nano /opt/tomcat/webapps/host-manager/META-INF/context.xml
### comment out VALVE className

# sudo systemctl restart tomcat

# now access web ui
# http://server_domain_or_IP:8080
# http://server_domain_or_IP:8080/manager/html
# http://server_domain_or_IP:8080/host-manager/html/
