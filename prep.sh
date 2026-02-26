#!/bin/bash
set -euo pipefail

NFSHOST=192.168.0.18

if [ $# -lt 1 ]; then
    echo 'usage: prep.sh SERIALNO'
    exit
fi

SERIAL=$1
BOOT=/mnt/tftpboot/boot/$SERIAL
ROOT=/mnt/tftpboot/root/$SERIAL

echo 'Creating directories...'
sudo mkdir $BOOT $ROOT

echo 'Setting up root...'
sudo tar xpf void-rpi*.tar.xz -C $ROOT
sudo cp 10-root.conf $ROOT/etc/ssh/sshd_config.d
sudo cp finalize.sh $ROOT/root
echo 'WARNING: system not yet finalized!' | sudo tee $ROOT/etc/motd > /dev/null

echo 'Setting up boot...'
#sudo cp -R firmware/boot/*.dtb firmware/boot/fixup* firmware/boot/start* firmware/boot/overlays/ $BOOT
sudo cp -pR $ROOT/boot/* $BOOT
sudo rm -rf $ROOT/boot/*
sed -e "s/SERIALNO/$SERIAL/g" cmdline.txt | sudo tee $BOOT/cmdline.txt > /dev/null
sudo cp config.txt $BOOT

echo 'Setting up fstab...'
echo "$NFSHOST:/srv/netboot/boot/$SERIAL /boot nfs4 _netdev,noatime,proto=tcp,async 0 0" | sudo tee -a $ROOT/etc/fstab > /dev/null
echo "$NFSHOST:/srv/netboot/root/$SERIAL / nfs4 _netdev,noatime,proto=tcp,async 0 0" | sudo tee -a $ROOT/etc/fstab > /dev/null

echo 'Setting repo mirror...'
sudo mkdir -p $ROOT/etc/xbps.d
sudo cp $ROOT/usr/share/xbps.d/*-repository-*.conf $ROOT/etc/xbps.d/
sudo sed -i 's|https://repo-default.voidlinux.org|https://repo-de.voidlinux.org|g' $ROOT/etc/xbps.d/*-repository-*.conf

echo 'Done.'