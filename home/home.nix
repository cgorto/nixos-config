{ pkgs, ... }:
{
  home.username = "gorto";
  home.homeDirectory = "/home/gorto";
  home.stateVersion = "25.05"; # do not change after install

  # ---- dotfiles carried over from bazzite (copies live in this repo) ----
  xdg.configFile = {
    "niri".source = ./dotfiles/niri;
    "fuzzel".source = ./dotfiles/fuzzel;
    "waybar".source = ./dotfiles/waybar;
    "mako".source = ./dotfiles/mako;
    "ghostty".source = ./dotfiles/ghostty;
    "helix".source = ./dotfiles/helix;
  };

  # ---- shell & dev ----
  programs.bash.enable = true;

  programs.git = {
    enable = true;
    userName = "Christian Gorton";
    userEmail = "gorto005@gmail.com";
  };

  programs.direnv = {
    enable = true;
    nix-direnv.enable = true; # cached devshells: instant `cd` into projects
  };

  programs.firefox.enable = true; # native; copy profile from .var/app after install

  home.packages = with pkgs; [
    # cli
    ripgrep
    fd
    gh
    # desktop
    swaylock
    swayidle
    xwayland-satellite # xwayland support for niri
    obsidian
    vlc
    obs-studio
    discord
    spotify
    blender
    # dev (project-specific stuff goes in per-project flakes instead)
    helix
    ghostty
  ];
}
