#!/bin/bash
# //----------------------------------------------------------------------------------------------------------
# // tomcat.sh
# //----------------------------------------------------------------------------------------------------------
# // tomcat installation script
# //----------------------------------------------------------------------------------------------------------
# // To run this script remotely:
# //   apt -y install curl
# //   /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/garjones/gareth.com/master/tomcat.sh)"
# //
# // Based on - https://www.tecmint.com/install-apache-tomcat-on-debian-10/
# //----------------------------------------------------------------------------------------------------------
# // Gareth Jones - gareth@gareth.com
# //----------------------------------------------------------------------------------------------------------


# //----------------------------------------------------------------------------------------------------------
# // Globabl variables
# //----------------------------------------------------------------------------------------------------------
WAITFORIT="TRUE" # set to true to debug


# //----------------------------------------------------------------------------------------------------------
# // Function : pause()
# //----------------------------------------------------------------------------------------------------------
# // Purpose  : Utility function to pause with a message
# //----------------------------------------------------------------------------------------------------------
function pause() {
    if [ "$WAITFORIT" == "TRUE" ]; then
        read -p "$*"        
    fi
}


# //----------------------------------------------------------------------------------------------------------
# // main()
# //----------------------------------------------------------------------------------------------------------
# update sources, install required components and upgrade the entire system
pause 'update and upgrade [Enter]'
apt update
apt -y install sudo curl wget default-jdk
apt -y upgrade

# allow wheel users to SUDO
pause 'enable sudo [Enter]'
echo "%wheel ALL=(ALL) ALL" | (EDITOR="tee -a" visudo)

# create user for tomcat service
pause 'create tomcat user [Enter]'
mkdir /opt/tomcat
groupadd tomcat
useradd -s /bin/false -g tomcat -d /opt/tomcat tomcat

# download tomcat and expand
pause 'download tomcat and expand [Enter]'
curl -O https://httpd-mirror.sergal.org/apache/tomcat/tomcat-9/v9.0.45/bin/apache-tomcat-9.0.45.tar.gz
sudo tar xzvf apache-tomcat-9*tar.gz -C /opt/tomcat --strip-components=1

# set permissions for the tomcat installation directory
pause 'set permissions for the tomcat installation directory [Enter]'
cd /opt/tomcat
chgrp -R tomcat /opt/tomcat
chmod -R g+r conf
chmod g+x conf
chown -R tomcat webapps/ work/ temp/ logs/

# create a tomcat systemd service file
pause 'create a tomcat systemd service file [Enter]'
wget https://raw.githubusercontent.com/garjones/gareth.com/master/tomcat.service -P /etc/systemd/system/

# refresh services & start the tomcat service
pause 'refresh services & start the tomcat service [Enter]'
systemctl daemon-reload
systemctl start tomcat
systemctl enable tomcat

# ask for web manager username and password
read -p    "Username:" user_var  
read -p -s "Password:" pwd_var  

# enable login for tomcat manager and host manager
pause 'enable login for tomcat manager and host manager [Enter]'
cp /opt/tomcat/conf/tomcat-users.xml /opt/tomcat/conf/tomcat-users.xml.bak
sed -i "s/<\/tomcat-users>/<role\ rolename=\"admin-gui,manager-gui\"\/>\n<\/tomcat-users>/g"  /opt/tomcat/conf/tomcat-users.xml
sed -i "s/<\/tomcat-users>/<user username=\"$user_var\" password=\"$pwd_var\" roles=\"admin-gui,manager-gui\"\/>\n<\/tomcat-users>/g"  /opt/tomcat/conf/tomcat-users.xml

# enable remote login to tomcat manager and host manager by removing ip restriction
pause 'enable remote login to tomcat manager and host manager [Enter]'
sed -i.bak '21,22d' /opt/tomcat/webapps/manager/META-INF/context.xml
sed -i.bak '21,22d' /opt/tomcat/webapps/host-manager/META-INF/context.xml
sudo systemctl restart tomcat

# now you can access web ui
# http://server_domain_or_IP:8080
# http://server_domain_or_IP:8080/manager/html
# http://server_domain_or_IP:8080/host-manager/html/

