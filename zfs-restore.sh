zpool import -Nf zroot
zfs rollback -r zroot/root@empty
zfs set mountpoint=legacy zroot/root
zfs set canmount=off zroot/root

zfs set mountpoint=legacy zroot/home
zfs set canmount=off zroot/home


zfs set mountpoint=legacy zroot/persist
zfs set canmount=off zroot/persist

zfs set mountpoint=legacy zroot/nix
zfs set canmount=off zroot/nix

zfs set mountpoint=legacy zroot/var
zfs set canmount=off zroot/var

zfs set mountpoint=legacy zroot/var/log
zfs set canmount=off zroot/var/log

zfs set mountpoint=legacy zroot/var/lib
zfs set canmount=off zroot/var/lib


mount -t zfs zroot/root /mnt
mkdir -p /mnt/persist /mnt/var/log /mnt/var/lib /mnt/etc/nixos /mnt/boot /mnt/boot /mnt/home /mnt/nix /mnt/etc/ssh /mnt/etc/NetworkManager

mount -t zfs zroot/home /mnt/home

mount -t zfs zroot/persist /mnt/persist
mkdir -p /mnt/persist/etc/nixos
mount -o bind /mnt/persist/etc/nixos /mnt/etc/nixos
mount -o bind /mnt/persist/etc/ssh /mnt/etc/ssh
mount -o bind /mnt/persist/etc/NetworkManager /mnt/etc/NetworkManager

mount -t zfs zroot/nix /mnt/nix
mount -t zfs zroot/var/log /mnt/var/log
mount -t zfs zroot/var/lib /mnt/var/lib
