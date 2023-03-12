# setting up carmine

1. partition the disk

```
/boot - 512M - fat32 - boot, esp - partlabel=nixos-boot
/nix  - 100% - ext4  - data      - partlabel=nixos
```

2. mount

```
mount -t tmpfs none /mnt
mkdir -p /mnt/{nix,boot}
mount /dev/disk/by-partlabel/nixos-boot /mnt/boot
mount /dev/disk/by-partlabel/nixos /mnt/nix

mkdir -p /mnt/nix/persist/{etc/nixos,var/lib,var/log,srv}
mount -o bind /mnt/var/lib /mnt/nix/persist/var/lib
mount -o bind /mnt/var/log /mnt/nix/persist/var/log
mount -o bind /mnt/srv /mnt/nix/persist/srv
```

3. install nixos

```
sudo nixos-install --flake github:oxy/nix-configs#carmine
```
