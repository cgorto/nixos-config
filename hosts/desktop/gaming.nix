{ pkgs, ... }:
{
  programs.steam = {
    enable = true;
    remotePlay.openFirewall = true;
    gamescopeSession.enable = true;
    extraCompatPackages = [ pkgs.proton-ge-bin ];
  };

  programs.gamescope = {
    enable = true;
    capSysNice = true;
  };

  programs.gamemode.enable = true;

  hardware.graphics = {
    enable = true;
    enable32Bit = true; # required for steam/proton
  };

  # some proton games need this; bazzite sets it too
  boot.kernel.sysctl."vm.max_map_count" = 2147483642;

  environment.systemPackages = with pkgs; [
    mangohud
    protontricks
    lutris
    umu-launcher
  ];
}
