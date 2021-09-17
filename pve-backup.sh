#!/bin/bash

# backup pve-cluster folder, contains proxmox .conf files
systemctl stop pve-cluster
cp /var/lib/pve-cluster/config.db /mnt/pve-cluster
systemctl start pve-cluster
