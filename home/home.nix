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
    "swayidle".source = ./dotfiles/swayidle;
    "swaylock".source = ./dotfiles/swaylock;
  };

  # polkit auth agent (niri has no DE providing one; needed for GUI privilege prompts)
  systemd.user.services.polkit-gnome-agent = {
    Unit = {
      Description = "polkit-gnome authentication agent";
      After = [ "graphical-session.target" ];
      PartOf = [ "graphical-session.target" ];
    };
    Service = {
      ExecStart = "${pkgs.polkit_gnome}/libexec/polkit-gnome-authentication-agent-1";
      Restart = "on-failure";
    };
    Install.WantedBy = [ "graphical-session.target" ];
  };

  # ---- shell & dev ----
  programs.bash.enable = true;

  programs.git = {
    enable = true;
    settings.user = {
      name = "Christian Gorton";
      email = "gorto005@gmail.com";
    };
  };

  programs.direnv = {
    enable = true;
    nix-direnv.enable = true; # cached devshells: instant `cd` into projects
  };

  programs.firefox = {
    enable = true; # native; copy profile from .var/app after install
    configPath = ".mozilla/firefox"; # keep classic path; silences stateVersion warning
  };

  home.packages = with pkgs; [
    # cli
    ripgrep
    fd
    gh
    # desktop -- everything niri config spawns or binds must be here
    waybar
    fuzzel
    mako
    foot # fallback terminal (Mod+Shift+Return)
    swaylock
    swayidle
    swaybg # spawned by niri config for wallpaper
    grim
    slurp
    wl-clipboard
    playerctl
    brightnessctl
    xwayland-satellite # xwayland support for niri
    obsidian
    vlc
    obs-studio
    discord
    spotify
    blender
    audacity
    kdePackages.dolphin
    kdePackages.ark # archive support in dolphin
    kdePackages.kio-extras # thumbnails, network browsing, etc.
    orca-slicer
    blockbench
    vintagestory
    zed-editor
    # dev (project-specific stuff goes in per-project flakes instead)
    helix
    pi-coding-agent # pi agent harness (badlogic/pi-mono)
    ghostty
  ];
}
