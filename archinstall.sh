#!/bin/bash
# //----------------------------------------------------------------------------
# // archinstall.sh
# //----------------------------------------------------------------------------
# // my script to automate arch installations
# //----------------------------------------------------------------------------
# // Gareth Jones - gareth@gareth.com
# //----------------------------------------------------------------------------


# //----------------------------------------------------------------------------
# // The following commands need to be entered at the console to enable SSH
# //----------------------------------------------------------------------------
#
# root@archiso ~ # setfont latarcyrheb-sun32  # only needed if too small
# root@archiso ~ # ip a
# root@archiso ~ # ping -c 3 8.8.8.8
# root@archiso ~ # ping www.google.com
# root@archiso ~ # passwd root
# root@archiso ~ # systemctl list-unit-files -t service | grep ssh
# root@archiso ~ # systemctl start sshd
# root@archiso ~ # touch archinstall.sh
# root@archiso ~ # chmod 777 archinstall.sh
#
# //----------------------------------------------------------------------------
# // ssh is now enabled, you can now connect remotely
# // ssh root@[ip address]
# // nano archinstall.sh
# // paste in the contents of this file and execute it
# //----------------------------------------------------------------------------

# //----------------------------------------------------------------------------
# // Globabl variables
# //----------------------------------------------------------------------------
WAITFORIT="FALSE" # set to true to debug

# //----------------------------------------------------------------------------
# // Function : pause()
# //----------------------------------------------------------------------------
# // Purpose  : Utility function to pause with a message
# //----------------------------------------------------------------------------
function pause() {
    if [ "$WAITFORIT" == "TRUE" ]; then
        read -p "$*"        
    fi
}

# //----------------------------------------------------------------------------
# // Function : phase1()
# //----------------------------------------------------------------------------
# // Purpose  : This phase runs on first boot of the arch.iso
# //----------------------------------------------------------------------------
function phase1() {
    # this is a hack
    P1="1"
    P2="2"
    P3="3"
    P4="4"

    # get disk name
    cat /proc/partitions
    read -p "Enter the device name ... " READ

    DISK=$READ

    # overwrite it with random data
    pause 'Wiping Disk [Enter]'
    badblocks -c 10240 -s -w -t random -v /dev/$DISK

    pause 'Create Partitions [Enter]'
    parted --script /dev/$DISK \
        mklabel gpt \
        mkpart ESP fat32 1MiB 200MiB \
        set 1 boot on \
        name 1 efi \
        mkpart primary 200MiB 800MiB \
        name 2 boot \
        mkpart primary 800MiB 32Gib \
        name 3 swap \
        mkpart primary 32GiB 100% \
        name 3 btrfs \
        print \
        quit


    # create LUKS volume
    pause 'Create LUKS volume [Enter]'
    cryptsetup luksFormat --cipher aes-xts-plain64 --key-size 256 --hash sha256 --use-random /dev/$DISK$P4

    # open the root luks volume
    pause 'Open LUKS volume [Enter]'
    cryptsetup luksOpen /dev/$DISK$P4 cryptroot

    # format Partitions
    pause 'Format Partitions [Enter]'
    mkfs.fat -F32 /dev/$DISK$P1
    mkfs.ext4 /dev/$DISK$P2
    mkswap /dev/$DISK$P3
    mkfs.btrfs /dev/mapper/cryptroot

    # mount the root filesystem
    pause 'Mount root filesystem [Enter]'
    mount -o noatime,compress=lzo,discard,ssd,defaults /dev/mapper/cryptroot /mnt

    # create the subvolumes
    pause 'Create subvolumes [Enter]'
    cd /mnt
    btrfs subvolume create __active
    btrfs subvolume create __active/rootvol
    btrfs subvolume create __active/home
    btrfs subvolume create __active/var
    btrfs subvolume create __snapshots
    btrfs subvolume create __snapshots/root
    btrfs subvolume create __snapshots/home
    btrfs subvolume create __snapshots/var
    cd 
    umount /mnt

    # mount the subvolumes
    pause 'Mount subvolumes [Enter]'
    mount -o noatime,compress=lzo,discard,ssd,defaults,subvol=__active/rootvol /dev/mapper/cryptroot /mnt
    mkdir /mnt/.snapshots
    mount -o noatime,compress=lzo,discard,ssd,defaults,subvol=__snapshots/root /dev/mapper/cryptroot /mnt/.snapshots
    mkdir /mnt/{home,var,boot}
    mount -o noatime,compress=lzo,discard,ssd,defaults,subvol=__active/home /dev/mapper/cryptroot /mnt/home
    mount -o noatime,compress=lzo,discard,ssd,defaults,subvol=__active/var /dev/mapper/cryptroot /mnt/var
    mkdir /mnt/home/.snapshots
    mkdir /mnt/var/.snapshots
    mount -o noatime,compress=lzo,discard,ssd,defaults,subvol=__snapshots/home /dev/mapper/cryptroot /mnt/home/.snapshots
    mount -o noatime,compress=lzo,discard,ssd,defaults,subvol=__snapshots/var /dev/mapper/cryptroot /mnt/var/.snapshots
    sync

    # mount other partitions
    pause 'Mount other partitions [Enter]'
    mount /dev/$DISK$P2 /mnt/boot
    mkdir /mnt/boot/efi
    mount /dev/$DISK$P1 /mnt/boot/efi
    swapon /dev/$DISK$P3
    swapon -a ; swapon -s

    # install Arch Linux
    pause 'Pacstrap [Enter]'
    pacstrap /mnt base base-devel linux linux-firmware nano btrfs-progs efibootmgr grub networkmanager openssh git --noconfirm

    # generate /etc/fstab
    pause 'Generate /etc/fstab [Enter]'
    genfstab -p -U /mnt >> /mnt/etc/fstab

    # copy script to /mnt ready to be run after chroot
    cp archinstall.sh /mnt/root/

    # chroot
    pause 'About to chroot after which script will terminate. Please re-run script for phase2 [Enter]'
    arch-chroot /mnt
}

# //----------------------------------------------------------------------------
# // Function : phase2()
# //----------------------------------------------------------------------------
# // Purpose  : This phase runs after we chroot
# //----------------------------------------------------------------------------
function phase2() {
    # set the timezone & hardware clock
    pause 'Set the timezone & hardware clock [Enter]'
    ln -s /usr/share/zoneinfo/America/Los_Angeles /etc/localtime
    hwclock --systohc --utc

    # Generate the required locales
    pause 'Generated the required locales [Enter]'
    cp /etc/locale.gen /etc/local.gen.bak
    echo "en_US.UTF-8 UTF-8" > /etc/locale.gen
    locale-gen

    # hostname
    pause 'Hostname & Hosts [Enter]'
    read -p "Enter your hostname : " MYHOST
    echo $MYHOST > /etc/hostname
    echo "127.0.0.1	localhost"                       >> /etc/hosts
    echo "::1		localhost"                       >> /etc/hosts
    echo "127.0.1.1	iamgroot.localdomain	$MYHOST" >> /etc/hosts
    cat /etc/hosts

    # mkinitcpio
    pause 'mkinitcpio, modify hooks [Enter]'
    cp /etc/mkinitcpio.conf /etc/mkinitcpio.conf.bak
    sed -i 's/HOOKS=(base\ udev\ autodetect\ modconf\ block\ filesystems\ keyboard\ fsck)/HOOKS="base\ udev\ autodetect\ modconf\ block\ encrypt\ filesystems\ keyboard\ fsck"/' /etc/mkinitcpio.conf
    mkinitcpio -p linux

    # set the root password
    echo 'Enter a new root password.'
    passwd root

    # autostart network manager & sshd
    systemctl enable NetworkManager.service
    systemctl enable sshd.service

    # install grub
    pause 'install grub [Enter]'
    grub-install --target=x86_64-efi --efi-directory=/boot/efi --recheck

    # configure grub to support LUKS kernel parameters
    pause 'configure grub to support LUKS kernel parameters [Enter]'
    cp /etc/default/grub /etc/default/grub.bak
    sed -i 's/GRUB_CMDLINE_LINUX_DEFAULT="loglevel=3 quiet"/GRUB_CMDLINE_LINUX_DEFAULT="cryptdevice=\/dev\/sda4:cryptroot\ root=\/dev\/mapper\/cryptroot\ rootflags=subvol=__active\/rootvol\ quiet"/' /etc/default/grub

    # generate grub.cfg file:
    grub-mkconfig -o /boot/grub/grub.cfg
    grub-mkconfig -o /boot/efi/EFI/arch/grub.cfg
    mkdir /boot/efi/EFI/BOOT
    cp /boot/efi/EFI/arch/grubx64.efi /boot/efi/EFI/BOOT/BOOTX64.EFI

    # Allow wheel users to SUDO
    pause 'Allow wheel users to SUDO [Enter]'
    echo "%wheel ALL=(ALL) ALL" | (EDITOR="tee -a" visudo)

    # Create User Account
    pause 'Create user account [Enter]'
    read -p "Enter your username: " USERNAME
    useradd -m -G wheel $USERNAME
    passwd $USERNAME

    # copy script to user folder ready for phase3
    cp archinstall.sh /home/$USERNAME

    # exit and reboot
    echo 'About to exit script. Time to reboot and login as a user.'
    echo 'Type exit [Enter] to exit CHROOT.'
    echo 'Type reboot [Enter] to reboot.'
    echo 'After rebooting ssh %USERNAME@<IP ADDRESS>.'
    echo 'Remember - You will need to enter your LUKS password at the console to boot.'
    pause 'Press [Enter]'
    sync
}

# //----------------------------------------------------------------------------
# // Function : phase3()
# //----------------------------------------------------------------------------
# // Purpose  : This phase runs in the end user account, on first boot
# //----------------------------------------------------------------------------
function phase3() {
    git clone https://aur.archlinux.org/yay.git
    cd yay/
    makepkg -si --noconfirm
    cd ..
    sudo rm -dR yay/
}


# //----------------------------------------------------------------------------
# // Function : main()
# //----------------------------------------------------------------------------
# // Purpose  : Controls which script runs, needs to be automated
# //----------------------------------------------------------------------------

# ask for phase number 
read -p "Enter phase number (1-3) : " PHASE

# select script
if [ "$PHASE" == "1" ]; then
    phase1
elif [ "$PHASE" == "2" ]; then
    phase2
elif [ "$PHASE" == "3" ]; then
    phase3
else
    echo "Error: Incorrect phase number entered"
fi
