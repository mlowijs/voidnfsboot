#!/bin/bash
set -euo pipefail

NFSHOST=192.168.11.10

if [ $# -lt 1 ]; then
    echo 'usage: prep.sh SERIALNO'
    exit
fi

SERIAL=$1
BOOT=/mnt/strmirr/netboot/boot/$SERIAL
ROOT=/mnt/strmirr/netboot/root/$SERIAL

echo 'Creating directories...'
doas mkdir $BOOT $ROOT

echo 'Setting up root...'
doas tar xpf void-rpi*.tar.xz -C $ROOT
doas cp 10-root.conf $ROOT/etc/ssh/sshd_config.d
doas cp finalize.sh $ROOT/root
echo 'WARNING: system not yet finalized!' | doas tee $ROOT/etc/motd > /dev/null

echo 'Setting up boot...'
#doas cp -R firmware/boot/*.dtb firmware/boot/fixup* firmware/boot/start* firmware/boot/overlays/ $BOOT
doas cp -pR $ROOT/boot/* $BOOT
doas rm -rf $ROOT/boot/*
sed -e "s/SERIALNO/$SERIAL/g" cmdline.txt | doas tee $BOOT/cmdline.txt > /dev/null
doas cp config.txt $BOOT

echo 'Setting up fstab...'
echo "$NFSHOST:/srv/netboot/boot/$SERIAL /boot nfs4 _netdev,noatime,proto=tcp,async 0 0" | doas tee -a $ROOT/etc/fstab > /dev/null
echo "$NFSHOST:/srv/netboot/root/$SERIAL / nfs4 _netdev,noatime,proto=tcp,async 0 0" | doas tee -a $ROOT/etc/fstab > /dev/null

echo 'Setting repo mirror...'
doas mkdir -p $ROOT/etc/xbps.d
doas cp $ROOT/usr/share/xbps.d/*-repository-*.conf $ROOT/etc/xbps.d/
doas sed -i 's|https://repo-default.voidlinux.org|https://repo-de.voidlinux.org|g' $ROOT/etc/xbps.d/*-repository-*.conf

echo 'Done.'