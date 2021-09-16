# Making a launch script for the VM
qm show 201 --pretty > launchvm.sh
nano launchvm.sh

# -drive 'if=pflash,unit=0,format=raw,readonly,file=/root//OVMF.fd' \

# -chardev 'socket,id=chrtpm,path=//var/tpm0/swtpm-sock' \
# -tpmdev 'emulator,id=tpm0,chardev=chrtpm' \
# -device 'tpm-tis,tpmdev=tpm0' \
# -bios /root/OVMF.fd

# Launch SWTPM like so
mkdir /var/tpm0
swtpm socket --tpmstate dir=/var/tpm0 --tpm2 --ctrl type=unixio,path=/var/tpm0/swtpm-sock

# Launch VM
./launchvm.sh
