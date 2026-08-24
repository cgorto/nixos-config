{ config, pkgs, ... }:
{
  imports = [ ./gaming.nix ];

  # ---- boot ----
  boot.loader.systemd-boot = {
    enable = true;
    configurationLimit = 5; # ESP only has ~586M free; keep generations trimmed
  };
  boot.loader.efi.canTouchEfiVariables = true;

  networking.hostName = "gorto-desktop";
  networking.networkmanager.enable = true;

  time.timeZone = "America/Denver";

  # ---- nvidia (RTX 3070 Ti) ----
  services.xserver.videoDrivers = [ "nvidia" ];
  hardware.nvidia = {
    modesetting.enable = true;
    open = true; # Ampere -> open kernel modules are the right choice
    package = config.boot.kernelPackages.nvidiaPackages.stable;
  };

  # ---- desktop: niri ----
  programs.niri.enable = true;
  security.polkit.enable = true;
  services.greetd = {
    enable = true;
    settings.default_session.command =
      "${pkgs.tuigreet}/bin/tuigreet --time --remember --cmd niri-session";
  };

  # ---- audio ----
  security.rtkit.enable = true; # realtime priority for pipewire
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };

  # ---- like bazzite had ----
  zramSwap.enable = true;
  hardware.bluetooth.enable = true;
  services.printing.enable = true;
  services.fwupd.enable = true;

  # access the NTFS drives (970EVO data drive, windows disk)
  boot.supportedFilesystems = [ "ntfs" ];
  services.udisks2.enable = true;

  # electron apps (discord, obsidian, zed) run native wayland
  environment.sessionVariables.NIXOS_OZONE_WL = "1";

  fonts.packages = with pkgs; [
    nerd-fonts.jetbrains-mono # waybar + ghostty configs depend on this
    noto-fonts
    noto-fonts-cjk-sans
    noto-fonts-color-emoji
  ];

  # ---- dev quality of life ----
  programs.nix-ld.enable = true; # random downloaded binaries just work
  nix.settings.experimental-features = [ "nix-command" "flakes" ];
  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 14d";
  };

  # ---- user ----
  users.users.gorto = {
    isNormalUser = true;
    uid = 1000; # must match the preserved home subvolume
    extraGroups = [ "wheel" "networkmanager" ];
    shell = pkgs.bash;
  };

  nixpkgs.config.allowUnfree = true;

  environment.systemPackages = with pkgs; [
    git
    vim
    wget
    efibootmgr # for phase-3 cleanup of bazzite boot entries
  ];

  system.stateVersion = "25.05"; # do not change after install
}
