
1. partition the disk

```
/boot - 512M - fat32 - boot, esp - partlabel=nixos-boot
/nix  - 100% - ext4  - data      - partlabel=nixos
```

nas-2t and nas-4t are a single btrfs volume.

2. mount

```
mount -t tmpfs none /mnt
mkdir -p /mnt/{nix,boot}
mount /dev/disk/by-partlabel/nixos-boot /mnt/boot
mount /dev/disk/by-partlabel/nixos /mnt/nix

mkdir -p /mnt/nix/persist/{var/log,srv}
mount -o bind /mnt/var/lib /mnt/nix/persist/var/lib
mount -o bind /mnt/srv /mnt/nix/persist/srv
```

3. create password

```
mkpasswd -m sha-512 > /mnt/nix/persist/secrets/oxy.passwd
```
