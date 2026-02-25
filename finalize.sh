#!/bin/bash
set -euo pipefail

read -p 'New hostname: ' HOSTNAME
echo $HOSTNAME > /etc/hostname

echo 'Updating and installing utilities...'
xbps-install -Syu xbps
xbps-install -Syu
xbps-install -Sy nfs-utils sv-netmount sudo nano void-repo-nonfree

echo 'Enabling netmount...'
ln -sf /etc/sv/netmount /var/service

echo 'Setting root password...'
chsh -s /bin/bash
passwd

echo 'Creating user michiel...'
useradd -mG wheel -s /bin/bash michiel
passwd michiel

echo 'Enabling sudo for wheel group...'
echo '%wheel ALL=(ALL:ALL) NOPASSWD: ALL' > /etc/sudoers.d/wheel

echo 'Cleaning up...'
rm /etc/ssh/sshd_config.d/10-root.conf
rm /etc/motd

echo 'Done.'