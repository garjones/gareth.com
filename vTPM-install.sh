#!/bin/bash

# check i am (g)root
if [[ $(id -u) -ne 0 ]] ; then echo "Please run as root" ; exit 1 ; fi

# install dependent packages
apt update -y
apt install -y automake expect gnutls-bin libgnutls28-dev wget git gawk m4 socat fuse libfuse-dev checkinstall libgmp-dev libtool libglib2.0-dev libjson-glib-dev libnspr4-dev libnss3-dev libssl-dev libtasn1-6-dev net-tools libseccomp-dev python-setuptools python3-pip python3-distutils build-essential uuid-dev iasl gcc nasm 

# this one causes a problem - do we need it?
apt install -y tpm-tools

# create directory
mkdir ~/vtpm
chmod ugoa+rwx -R ~/vtpm

# libtpms
git clone https://github.com/stefanberger/libtpms.git ~/vtpm/libtpms
cd ~/vtpm/libtpms
./bootstrap.sh
./configure  --with-openssl --with-tpm2 
make
checkinstall --install=yes
cp ~/vtpm/libtpms/*.deb ~/vtpm

# swtpm
git clone https://github.com/stefanberger/swtpm.git ~/vtpm/swtpm
cd ~/vtpm/swtpm
./autogen.sh
./configure  --prefix=/usr --with-openssl --with-tpm2
make
make install
checkinstall --install=yes
cp ~/vtpm/swtpm/*.deb ~/vtpm
ldconfig

# OVMF with Secureboot and TPM - compile
git clone https://github.com/tianocore/edk2 ~/vtpm/edk2
cd ~/vtpm/edk2
git submodule update --init
make -C BaseTools
. edksetup.sh
build -p OvmfPkg/OvmfPkgX64.dsc -b RELEASE -a X64 -t GCC5 -D TPM_ENABLE -D TPM_CONFIG_ENABLE -D SECURE_BOOT_ENABLE -D NETWORK_TLS_ENABLE
cp ~/vtpm/edk2/Build/OvmfX64/RELEASE_GCC5/FV/OVMF.fd ~/vtpm

# download the launch script
cd ~/vtpm
wget https://raw.githubusercontent.com/garjones/gareth.com/master/vTPM-launch.sh
chmod +x vTPM-launch.sh
