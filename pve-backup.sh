#!/bin/bash

# backup pve-cluster folder, contains proxmox .conf files
systemctl stop pve-cluster
cp -r /var/lib/pve-cluster /mnt
systemctl start pve-cluster
