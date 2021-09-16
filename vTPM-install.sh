#!/bin/bash

# https://www.reddit.com/r/Proxmox/comments/oai5cr/guide_vtpm_and_secureboot_capability_in_a/
# https://github.com/rayures/vTPM
# https://github.com/tianocore/tianocore.github.io/wiki/Common-instructions
# https://github.com/stefanberger/
# https://www.reddit.com/r/Proxmox/comments/oai5cr/guide_vtpm_and_secureboot_capability_in_a/

# check i am (g)root
if [[ $(id -u) -ne 0 ]] ; then echo "Please run as root" ; exit 1 ; fi

# install dependent packages
apt update -y
apt -y install automake expect gnutls-bin libgnutls28-dev git gawk m4 socat fuse libfuse-dev checkinstall tpm-tools libgmp-dev libtool libglib2.0-dev libjson-glib-dev libnspr4-dev libnss3-dev libssl-dev libtasn1-6-dev net-tools libseccomp-dev python-setuptools python3-pip python3-distutils build-essential uuid-dev iasl gcc nasm 

# create directory
mkdir ~/vtpm
chmod ugoa+rwx -R ~/vtpm

# libtpms
git clone https://github.com/stefanberger/libtpms.git ~/vtpm/libtpms
cd ~/vtpm/libtpms
./bootstrap.sh
./configure  --with-openssl --with-tpm2 
make
checkinstall --install=yes --default
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
cd ~/edk2
git submodule update --init
make -C BaseTools
. edksetup.sh
build -p OvmfPkg/OvmfPkgX64.dsc -b RELEASE -a X64 -t GCC5 -D TPM_ENABLE -D TPM_CONFIG_ENABLE -D SECURE_BOOT_ENABLE -D NETWORK_TLS_ENABLE
cp ~/edk2/Build/OvmfX64/RELEASE_GCC5/FV/OVMF.fd ~/vtpm