#!/bin/bash

#########################
# INCOMPLETE DO NOT RUN #
#########################

# //----------------------------------------------------------------------------------------------------------
# // proxmox-pass.sh
# //----------------------------------------------------------------------------------------------------------
# // incomplete Proxmox passthrough script
# //----------------------------------------------------------------------------------------------------------
# // To run this script see:
# // https://gareth.com/index.php/2021/03/05/proxmox-pci-passthrough/
# //----------------------------------------------------------------------------------------------------------
# // Gareth Jones - gareth@gareth.com
# //----------------------------------------------------------------------------------------------------------


# enable pci passthrough

# configure grub
intel_iommu=on
sed -i.bak "s/quiet/quiet\ intel_iommu=on/g"  /etc/default/grub
update-grub

# vfio modules
printf "vfio\nvfio_iommu_type1\nvfio_pci\nvfio_virqfd\n" >> /etc/modules

# blacklisting drivers
echo "blacklist nvidia" >> /etc/modprobe.d/blacklist.conf

########
# adding gpu to vfio - this section is not autmated.
########
lspci | grep VGA
lspci -n -s 65:00
echo "options vfio-pci ids=10de:1cb2,10de:0fb9 disable_vga=1" > /etc/modprobe.d/vfio.conf
update-initramfs -u
reset

# add entries to the machine config file
cd /etc/pve/qemu-server
nano 100.conf
######
bios: ovmf
efidisk0: zfs-hot:vm-100-disk-2,size=128K
hostpci0: 65:00,x-vga=1,pcie=1
machine: q35
vga: none
