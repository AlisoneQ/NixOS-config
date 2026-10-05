{ inputs, config, pkgs, ... }:

{
  # Imports
  imports = [
    inputs.zen-browser.homeModules.beta
  ];


  # Shell
  programs.zsh = {
    enable = true;
    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;
    history.size = 10000;
  };

  programs.starship = {
    enable = true;
    enableZshIntegration = true;
  };


  # Applications
  programs.zen-browser = {
    enable = true;
    setAsDefaultBrowser = true;
  };

  programs.vscode = {
    enable = true;
    package = pkgs.vscode.overrideAttrs (old: {
      postFixup = (old.postFixup or "") + ''
        wrapProgram $out/bin/code --add-flags "--ozone-platform=wayland"
         '';
       });
  };

  # Home Manager
  home.username = "alisoneq";
  home.homeDirectory = "/home/alisoneq";
  home.stateVersion = "25.11";

  programs.home-manager.enable = true;

  home.pointerCursor = {
    enable = true;
    gtk.enable = true;
	x11.enable = true;
	package = pkgs.bibata-cursors;
	name = "Bibata-Modern-Classic";
	size = 18;
  };

  systemd.user.services.ydotoold = {
    Unit = {
      Description = "ydotool daemon";
    };
  
    Service = {
      ExecStart = "${pkgs.ydotool}/bin/ydotoold";
      Restart = "on-failure";
      RestartSec = 2;
    };
  
    Install = {
      WantedBy = [ "default.target" ];
    };
  };

  # Configuration files
  xdg.configFile."niri/config.kdl".source =
    config.lib.file.mkOutOfStoreSymlink "/etc/nixos/niri/config.kdl";
  xdg.configFile."kitty/kitty.conf".source = ./kitty/kitty.conf;
  xdg.configFile."starship.toml".source = ./starship/starship.toml;
  xdg.configFile."nvim".source =
    config.lib.file.mkOutOfStoreSymlink "/etc/nixos/nvim";
  xdg.configFile."fastfetch/config.jsonc".source = ./fastfetch/config.jsonc;
  xdg.configFile."fastfetch/logo.txt".source = ./fastfetch/logo.txt;

  # Packages
  home.packages = with pkgs; [
    # Desktop / Wayland
    niri
    quickshell
    fuzzel
    mako
    awww
    swaylock
    swayidle
    xwayland-satellite

    # Desktop utilities
    networkmanagerapplet
    blueman
    wl-clipboard
    cliphist
    grim
    slurp
    brightnessctl
    playerctl
    upower
    pavucontrol
    ydotool

    # Terminal
    kitty
    fastfetch
    neovim
    micro
    htop
    yazi

    # Applications
    firefox
    discord
    steam
    pinta

    # CLI / Development
    git
    wget
  ];
}
