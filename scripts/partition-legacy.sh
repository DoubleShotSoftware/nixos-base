#!/usr/bin/env bash
dd if=/dev/zero of=$DISK bs=128M count=10 oflag=sync status=progress
wipefs $DISK
parted $DISK mklabel msdos
sgdisk -n1:1M:+512M -t2:8300 $DISK
sgdisk -n2:0:0 -t3:8308 $DISK

mkfs.ext2 ${DISK}1
mkfs.btrfs ${DISK}2

mount ${DISK}2 /mnt
mkdir -p /mnt/boot
mount ${DISK}1 /mnt/boot
btrfs subvolume create /mnt/home
mount -t btrfs -o subvol=home ${DISK}3 /mnt/home
fallocate -l 5G /mnt/spacer.img
