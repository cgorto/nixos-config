# Install runbook — Bazzite → NixOS (keep home)

**Fallback at every step until Phase 3: reboot → firmware boot menu → Fedora = old Bazzite, fully intact.**

## Pre-flight (done)
- [x] Backup on 970EVO (`bazzite-backup-*/`)
- [x] Config pushed: github.com/cgorto/nixos-config
- [x] Secure Boot disabled

## Phase 1 — kexec into installer

From Bazzite, in a HOST terminal (not distrobox):

```bash
cd /tmp
curl -LO https://github.com/nix-community/nixos-images/releases/download/nixos-unstable/nixos-kexec-installer-noninteractive-x86_64-linux.tar.gz
sudo tar -xzf nixos-kexec-installer-noninteractive-x86_64-linux.tar.gz -C /root 2>/dev/null || sudo tar -xzf nixos-kexec-installer-noninteractive-x86_64-linux.tar.gz -C /tmp
sudo /root/kexec/run || sudo /tmp/kexec/run
```

Screen goes black ~30s, then a NixOS console appears. Log in: root (no password on console).
Ethernet comes up automatically via DHCP.

## Phase 2 — mount + install

Disk facts (verify with `lsblk` before proceeding!):
- `nvme1n1p1` = ESP (vfat, UUID `E82B-D348`)
- `nvme1n1p3` = bazzite btrfs (UUID `19260a91-cddd-45ec-af33-c8e39a71031c`), subvols: root, var, home

**NO mkfs. NO partitioning. Nothing gets formatted.**

```bash
# create nixos root subvolume alongside bazzite's
mount -o subvolid=5 /dev/nvme1n1p3 /mnt
btrfs subvolume create /mnt/@nixos
umount /mnt

# mount the install target
mount -o subvol=@nixos,compress=zstd:1 /dev/nvme1n1p3 /mnt
mkdir -p /mnt/home /mnt/boot
mount -o subvol=home,compress=zstd:1 /dev/nvme1n1p3 /mnt/home
mount /dev/nvme1n1p1 /mnt/boot

# sanity: this MUST show your files
ls /mnt/home/gorto/dev

# cross-check generated config against the repo's hardware-configuration.nix
nixos-generate-config --root /mnt --show-hardware-config | grep -A4 'fileSystems'

# install (flake is public, no auth needed)
nixos-install --flake github:cgorto/nixos-config#gorto-desktop
# sets root password at the end; user password is initialPassword "changeme"

reboot
```

## Phase 3 — first boot

1. systemd-boot menu → NixOS → SDDM (astronaut) → login gorto/changeme → niri.
2. Immediately: `passwd` (and `sudo passwd root` if desired).
3. Sanity: `ls ~/dev`, waybar up, `Mod+Return` terminal, steam launches, library present.
4. Firefox profile: `cp -r ~/.var/app/org.mozilla.firefox/.mozilla ~/` (then remove flatpak leftovers later).
5. Clone config: `git clone https://github.com/cgorto/nixos-config ~/dev/nixos-config-new`
   (or just fix the remote in the existing checkout). Rebuilds: `sudo nixos-rebuild switch --flake ~/dev/nixos-config`

## Phase 4 — cleanup (AFTER a week of daily driving)

```bash
# reclaim bazzite's system space (~50-100G)
sudo mount -o subvolid=5 /dev/nvme1n1p3 /mnt2  # mkdir first
sudo btrfs subvolume delete /mnt2/root/ostree/deploy/default/deploy/*  # if nested
sudo btrfs subvolume delete /mnt2/root /mnt2/var

# remove bazzite bootloader
sudo rm -rf /boot/EFI/fedora
sudo efibootmgr -b 2 -B     # "Fedora" entry — VERIFY entry number with efibootmgr first
sudo efibootmgr -b 0 -B     # stale Windows entry pointing at deleted partition

# home cruft, gradually
rm -rf ~/.var ~/.local/share/flatpak ~/.local/share/containers
rm -rf ~/.rustup ~/.cargo ~/.npm ~/.pnpm-store ~/.bun
```

Windows: unchanged on sda, boot via firmware boot menu (F11/F8/Del at POST).
