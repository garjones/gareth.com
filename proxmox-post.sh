#!/bin/bash
# //----------------------------------------------------------------------------------------------------------
# // proxmox-post.sh
# //----------------------------------------------------------------------------------------------------------
# // Post installation script to get a basic Proxmox 6.x server running
# //----------------------------------------------------------------------------------------------------------
# // To run this script remotely:
# //   apt -y install curl
# //   /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/garjones/gareth.com/master/proxmox-post.sh)"
# //
# // Based on - https://www.tecmint.com/install-apache-tomcat-on-debian-10/
# //----------------------------------------------------------------------------------------------------------
# // Gareth Jones - gareth@gareth.com
# //----------------------------------------------------------------------------------------------------------

# //----------------------------------------------------------------------------------------------------------
# // Enter from the client workstation to allow public key based SSH
# //----------------------------------------------------------------------------------------------------------
# ssh-copy-id -i ~/.ssh/garjones.pub root@192.168.33.5

# //----------------------------------------------------------------------------------------------------------
# // make a backup of sources.list
# //----------------------------------------------------------------------------------------------------------
mv /etc/apt/sources.list /etc/apt/sources.list.old

# //----------------------------------------------------------------------------------------------------------
# // create a new sources.list
# //----------------------------------------------------------------------------------------------------------
echo "deb http://ftp.us.debian.org/debian buster main contrib non-free" > /etc/apt/sources.list
echo "deb-src http://ftp.debian.org/debian/ buster main contrib non-free" >> /etc/apt/sources.list
echo "deb http://ftp.us.debian.org/debian buster-updates main contrib non-free" >> /etc/apt/sources.list
echo "" >> /etc/apt/sources.list
echo "# security updates" >> /etc/apt/sources.list
echo "deb http://security.debian.org buster/updates main contrib non-free" >> /etc/apt/sources.list
echo "deb http://security.debian.org/debian-security buster/updates main contrib non-free" >> /etc/apt/sources.list
echo "deb-src http://security.debian.org/debian-security buster/updates main contrib non-free" >> /etc/apt/sources.list

# //----------------------------------------------------------------------------------------------------------
# // add proxmox no subscription sources
# //----------------------------------------------------------------------------------------------------------
echo "deb http://download.proxmox.com/debian/pve buster pve-no-subscription" > /etc/apt/sources.list.d/pve-nosubscription.list
echo "deb http://download.proxmox.com/debian/ceph-nautilus buster main" > /etc/apt/sources.list.d/pve-ceph.list
wget http://download.proxmox.com/debian/proxmox-ve-release-6.x.gpg -O /etc/apt/trusted.gpg.d/proxmox-ve-release-6.x.gpg
chmod +r /etc/apt/trusted.gpg.d/proxmox-ve-release-6.x.gpg  # optional, if you have a non-default umask

# //----------------------------------------------------------------------------------------------------------
# // disable proxmox enterprise source
# //----------------------------------------------------------------------------------------------------------
sed -i 's/deb/#deb/' /etc/apt/sources.list.d/pve-enterprise.list

# //----------------------------------------------------------------------------------------------------------
# // run updates
# //----------------------------------------------------------------------------------------------------------
apt update
apt -y dist-upgrade

# //----------------------------------------------------------------------------------------------------------
# // download templates
# // if any fail because version has changed use # pveam available
# //----------------------------------------------------------------------------------------------------------
pveam download local archlinux-base_20200508-1_amd64.tar.gz
pveam download local centos-8-default_20191016_amd64.tar.xz
pveam download local debian-10.0-standard_10.0-1_amd64.tar.gz
pveam download local fedora-32-default_20200430_amd64.tar.xz
pveam download local gentoo-current-default_20200310_amd64.tar.xz
pveam download local opensuse-15.1-default_20190719_amd64.tar.xz
pveam download local ubuntu-20.04-standard_20.04-1_amd64.tar.gz

# //----------------------------------------------------------------------------------------------------------
# // download archlinux iso and move to correct folder
# //----------------------------------------------------------------------------------------------------------
wget ca.us.mirror.archlinux-br.org/iso/2021.01.01/archlinux-2021.01.01-x86_64.iso
mv archlinux-2021.01.01-x86_64.iso /var/lib/vz/template/iso/
