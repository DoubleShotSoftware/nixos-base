#!/usr/bin/env bash

zpool create -f -o ashift=12         \
             -O acltype=posixacl       \
             -O relatime=on            \
             -O xattr=sa               \
             -O dnodesize=legacy       \
             -O normalization=formD    \
             -O mountpoint=none        \
             -O canmount=off           \
             -O compress=lz4           \
             -O devices=off            \
             -O encryption=on \
             -O keylocation=prompt  \
             -O keyformat=passphrase \
             zroot $1

zfs create -o mountpoint=legacy -o canmount=off zroot/root
zfs snapshot zroot/root@empty
zfs create -o mountpoint=legacy -o canmount=off zroot/home
zfs create -o mountpoint=legacy -o canmount=off zroot/home/workspaces
zfs create -o mountpoint=legacy -o canmount=off zroot/persist
zfs create -o mountpoint=legacy -o canmount=off zroot/nix
zfs create -o mountpoint=legacy -o canmount=off zroot/var
zfs create -o mountpoint=legacy -o canmount=off zroot/var/log
zfs create -o mountpoint=legacy -o canmount=off zroot/var/lib

mount -t zfs zroot/root /mnt
mkdir -p /mnt/persist /mnt/var/log /mnt/var/lib /mnt/etc/nixos /mnt/boot /mnt/boot /mnt/home /mnt/nix /mnt/etc/ssh /mnt/etc/NetworkManager /mnt/persist/etc/ssh /mnt/persist/etc/NetworkManager

mount -t zfs zroot/home /mnt/home
mkdir -p /mnt/home/workspaces
mount -t zfs zroot/home/workspaces /mnt/home/workspaces 

mount -t zfs zroot/persist /mnt/persist
mkdir -p /mnt/persist/etc/nixos /mnt/persist/etc/NetworkManager /mnt/persist/etc/ssh
mount -o bind /mnt/persist/etc/nixos /mnt/etc/nixos
mount -o bind /mnt/persist/etc/ssh /mnt/etc/ssh
mount -o bind /mnt/persist/etc/NetworkManager /mnt/etc/NetworkManager

mount -t zfs zroot/nix /mnt/nix
mount -t zfs zroot/var/log /mnt/var/log
mount -t zfs zroot/var/lib /mnt/var/lib
