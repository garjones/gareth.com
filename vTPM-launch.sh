#!/bin/bash

# launch script for Proxmox VM with a virtual TPM

# check for VMID
re='^[0-9]+$'
if ! [[ $1 =~ $re ]] ; then echo "Usage: $0 <VMID>" ; exit 1 ; fi 

# dump vm configuration into temp launch script
qm show $1 --pretty > launch$1.sh
chmod +x launch$1.sh

# replace OVMF with our updated one
# -drive 'if=pflash,unit=0,format=raw,readonly=on,file=/usr/share/pve-edk2-firmware//OVMF_CODE.fd' \
# -drive 'if=pflash,unit=0,format=raw,readonly,file=/root//OVMF.fd' \
sed -i 's/usr\/share\/pve-edk2-firmware\/\/OVMF_CODE.fd/root\/vtpm\/\/OVMF.fd/' launch$1.sh

# add a \ to the last line
sed -i '$ s/$/ \\/' launch$1.sh

# appen file with required extra lines
echo " -chardev 'socket,id=chrtpm,path=//var/tpm$1/swtpm-sock' \\" >> launch$1.sh
echo " -tpmdev 'emulator,id=tpm$1,chardev=chrtpm' \\"              >> launch$1.sh
echo " -device 'tpm-tis,tpmdev=tpm$1' \\"                          >> launch$1.sh
echo " -bios /root/OVMF.fd"                                        >> launch$1.sh

# create folder for the socket
[ ! -d "/var/tpm$1" ] && mkdir /var/tpm$1

# launch the service in the background
swtpm socket --tpmstate dir=/var/tpm$1 --tpm2 --ctrl type=unixio,path=/var/tpm$1/swtpm-sock &

# launch VM
./launch$1.sh

# delete temp launch script
rm ./launch$1.sh
