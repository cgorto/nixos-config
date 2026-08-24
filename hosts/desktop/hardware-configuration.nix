{ config, lib, modulesPath, ... }:
{
  # Pre-filled from the live Bazzite system.
  # VERIFY against `nixos-generate-config --root /mnt` output during install!
  imports = [ (modulesPath + "/installer/scan/not-detected.nix") ];

  boot.initrd.availableKernelModules = [ "xhci_pci" "ahci" "nvme" "usbhid" "sd_mod" ];
  boot.kernelModules = [ "kvm-intel" ];

  # nvme1n1p3 - existing bazzite btrfs volume (NOT reformatted)
  fileSystems."/" = {
    device = "/dev/disk/by-uuid/19260a91-cddd-45ec-af33-c8e39a71031c";
    fsType = "btrfs";
    options = [ "subvol=@nixos" "compress=zstd:1" "discard=async" ];
  };

  # existing home subvolume, preserved from bazzite
  fileSystems."/home" = {
    device = "/dev/disk/by-uuid/19260a91-cddd-45ec-af33-c8e39a71031c";
    fsType = "btrfs";
    options = [ "subvol=home" "compress=zstd:1" "discard=async" ];
  };

  # nvme1n1p1 - existing ESP, shared with bazzite until phase-3 cleanup
  fileSystems."/boot" = {
    device = "/dev/disk/by-uuid/E82B-D348";
    fsType = "vfat";
    options = [ "umask=0077" ];
  };

  swapDevices = [ ]; # zram configured in configuration.nix

  nixpkgs.hostPlatform = "x86_64-linux";
  hardware.cpu.intel.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
}
