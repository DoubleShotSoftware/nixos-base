#!/usr/bin/env bash
dd if=/dev/zero of=$DISK bs=128M count=10 oflag=sync status=progress
wipefs $DISK
parted /dev/vda mklabel gpt
sgdisk -n1:1M:+512M -t1:EF00 $DISK
sgdisk -n2:513M:+512M -t2:8300 $DISK
sgdisk -n3:0:0 -t3:8308 $DISK

mkfs.vfat ${DISK}1
mkfs.ext2 ${DISK}2
mkfs.btrfs ${DISK}3

mount ${DISK}3 /mnt
mkdir -p /mnt/boot
mount ${DISK}2 /mnt/boot
mkdir -p /mnt/boot/EFI
mount ${DISK}1 /mnt/boot/EFI
btrfs subvolume create /mnt/home
mount -t btrfs -o subvol=home ${DISK}3 /mnt/home
fallocate -l 5G /mnt/spacer.img
