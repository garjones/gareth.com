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
apt upgrade -y

# create User Account
useradd -m -G wheel garjones
passwd garjones

# allow wheel users to SUDO
apt install sudo curl wget
echo "%wheel ALL=(ALL) ALL" | (EDITOR="tee -a" visudo)

## LOGOUT AND LOGIN AS USER

# Install Java on Debian 10
sudo apt install default-jdk
java -version

# Install Tomcat in Debian 10
sudo mkdir /opt/tomcat
sudo groupadd tomcat
sudo useradd -s /bin/false -g tomcat -d /opt/tomcat tomcat

# Download tomcat and expand
curl -O https://httpd-mirror.sergal.org/apache/tomcat/tomcat-9/v9.0.45/bin/apache-tomcat-9.0.45.tar.gz
sudo tar xzvf apache-tomcat-9*tar.gz -C /opt/tomcat --strip-components=1

# Lockdown the tomcat installation directory
cd /opt/tomcat
sudo chgrp -R tomcat /opt/tomcat
sudo chmod -R g+r conf
sudo chmod g+x conf
sudo chown -R tomcat webapps/ work/ temp/ logs/

# Create a Tomcat systemd Service File

# This command displays the JAVA_HOME
sudo update-java-alternatives -l

sudo nano /etc/systemd/system/tomcat.service
###########
[Unit]
Description=Apache Tomcat Web Application Container
After=network.target

[Service]
Type=forking

Environment=JAVA_HOME=/usr/lib/jvm/java-1.11.0-openjdk-amd64
Environment=CATALINA_PID=/opt/tomcat/temp/tomcat.pid
Environment=CATALINA_HOME=/opt/tomcat
Environment=CATALINA_BASE=/opt/tomcat
Environment='CATALINA_OPTS=-Xms512M -Xmx1024M -server -XX:+UseParallelGC'
Environment='JAVA_OPTS=-Djava.awt.headless=true -Djava.security.egd=file:/dev/./urandom'

ExecStart=/opt/tomcat/bin/startup.sh
ExecStop=/opt/tomcat/bin/shutdown.sh

User=tomcat
Group=tomcat
UMask=0007
RestartSec=10
Restart=always

[Install]
WantedBy=multi-user.target
#############

sudo systemctl daemon-reload

sudo systemctl start tomcat
systemctl status tomcat
sudo systemctl enable tomcat

sudo nano /opt/tomcat/conf/tomcat-users.xml
#####
<role rolename="admin-gui,manager-gui"/> 
<user username="admin" password="password" roles="admin-gui,manager-gui"/>
#####

sudo nano /opt/tomcat/webapps/manager/META-INF/context.xml
sudo nano /opt/tomcat/webapps/host-manager/META-INF/context.xml
### comment out VALVE className

sudo systemctl restart tomcat


# now access web ui
# http://server_domain_or_IP:8080
# http://server_domain_or_IP:8080/manager/html
# http://server_domain_or_IP:8080/host-manager/html/




