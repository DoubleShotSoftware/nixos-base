#!/usr/bin/env bash
umount -f /mnt/etc/nixos
umount -f /mnt/etc/ssh
umount -f /mnt/etc/NetworkManager
umount -f /mnt/home/workspaces
umount -f /mnt/home
umount -f /mnt/nix
umount -f /mnt/var/log
umount -f /mnt/var/lib
umount -f /mnt/boot/EFI
umount -f /mnt/boot
umount -f /mnt/persist
umount -f /mnt

zfs set canmount=off zroot/home
zfs set mountpoint=legacy zroot/home

zfs set canmount=off zroot/home/workspaces
zfs set mountpoint=legacy zroot/home/workspaces

zfs set canmount=off zroot/nix
zfs set mountpoint=legacy zroot/nix

zfs set canmount=off zroot/persist
zfs set mountpoint=legacy zroot/persist

zfs set canmount=off zroot/root
zfs set mountpoint=none zroot/root

zfs set canmount=off zroot/var/lib
zfs set mountpoint=legacy zroot/var/lib

zfs set canmount=off zroot/var/log
zfs set mountpoint=legacy zroot/var/log
