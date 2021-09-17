# launch script for Proxmox VM with a virtual TPM

# check for VMID
re='^[0-9]+$'
if ! [[ $1 =~ $re ]] ; then echo "Usage: $0 <VMID>" ; exit 1 ; fi 

# dump vm configuration into temp launch script
qm show $1 --pretty > launch$1.sh

# -drive 'if=pflash,unit=0,format=raw,readonly,file=/root//OVMF.fd' \

# -chardev 'socket,id=chrtpm,path=//var/tpm0/swtpm-sock' \
# -tpmdev 'emulator,id=tpm0,chardev=chrtpm' \
# -device 'tpm-tis,tpmdev=tpm0' \
# -bios /root/OVMF.fd

# create folder for the socket
[ ! -d "/var/tpm$1" ] && mkdir /var/tpm$1

# launch the service in the background
swtpm socket --tpmstate dir=/var/tpm$1 --tpm2 --ctrl type=unixio,path=/var/tpm$1/swtpm-sock &

# launch VM
#./launchvm.sh
