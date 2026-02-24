#!/bin/bash

TARGET=fd9f0f00
NFSHOST=192.168.0.18

OPWD=`pwd`
BOOT=/mnt/tftpboot/boot/$TARGET
ROOT=/mnt/tftpboot/root/$TARGET

echo 'Creating directories...'
sudo mkdir $BOOT $ROOT

echo 'Copying boot...'
cd $OPWD/firmware-master/boot
sudo cp -R *.dtb fixup* start* overlays/ $BOOT

echo 'Configuring boot...'
cd $OPWD
sed -e "s/SERIALNO/$TARGET/g" cmdline.txt | sudo tee $BOOT/cmdline.txt > /dev/null
sudo cp config.txt $BOOT

echo 'Copying root...'
cd $OPWD
sudo tar xpf void-rpi*.tar.xz -C $ROOT

echo 'Copying kernel...'
sudo cp $ROOT/boot/kernel* $BOOT
sudo rm -rf $ROOT/boot/*

echo 'Setting up fstab...'
echo "$NFSHOST:/srv/tftpboot/boot/$TARGET /boot nfs4 _netdev,noatime,proto=tcp 0 0" | sudo tee -a $ROOT/etc/fstab > /dev/null
echo "$NFSHOST:/srv/tftpboot/root/$TARGET / nfs4 _netdev,noatime,proto=tcp 0 0" | sudo tee -a $ROOT/etc/fstab > /dev/null

echo 'Enabling SSH access for root...'
cd $OPWD
sudo cp 10-root.conf $ROOT/etc/ssh/sshd_config.d

echo 'Copying finalize script...'
cd $OPWD
sudo cp finalize.sh $ROOT/root
echo 'WARNING: system not yet finalized!' | sudo tee $ROOT/etc/motd > /dev/null

echo 'Done.'