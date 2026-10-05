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

/*
    programs.vscode = {
    enable = true;
    package = pkgs.vscode.overrideAttrs (old: {
      postFixup = (old.postFixup or "") + ''
        wrapProgram $out/bin/code --add-flags "--ozone-platform=wayland"
         '';
       });
    };
*/

  # Home Manager
  home.username = "alisoneq";
  home.homeDirectory = "/home/alisoneq";
  home.stateVersion = "25.11";

  programs.home-manager.enable = true;


  # Configuration files
  xdg.configFile."niri/config.kdl".source =
    config.lib.file.mkOutOfStoreSymlink "/etc/nixos/niri/config.kdl";
  xdg.configFile."kitty/kitty.conf".source = ./kitty/kitty.conf;
  xdg.configFile."starship.toml".source = ./starship/starship.toml;
  xdg.configFile."nvim".source =
    config.lib.file.mkOutOfStoreSymlink "/etc/nixos/nvim";
  xdg.configFile."fastfetch/config.jsonc".source = ./fastfetch/config.jsonc;
  xdg.configFile."fastfetch/logo.txt".source = ./fastfetch/logo.txt;
  xdg.configFile."waybar/config.jsonc".source =
    config.lib.file.mkOutOfStoreSymlink "/etc/nixos/waybar/config.jsonc";
  xdg.configFile."waybar/style.css".source =
    config.lib.file.mkOutOfStoreSymlink "/etc/nixos/waybar/style.css";
  xdg.configFile."waybar/theme.css".source =
    config.lib.file.mkOutOfStoreSymlink "/etc/nixos/waybar/theme.css";


  # Packages
  home.packages = with pkgs; [
    # Desktop / Wayland
    niri
    waybar
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
	  vscodium
    pinta

    # CLI / Development
    git
    wget
  ];
}
