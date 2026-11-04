{ inputs, config, pkgs, lib, isLaptop ? false, ... }:

{
  # Imports
  imports = [
    inputs.zen-browser.homeModules.beta
    inputs.nix-flatpak.homeManagerModules.nix-flatpak
  ];


  # Shell
  programs.zsh = {
    enable = true;
    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;
    history.size = 10000;
    loginExtra = ''
        if [[ "$(tty)" == "/dev/tty1" ]]; then
          exec niri-session
        fi
    '';
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
  home.homeDirectory = "/home/${config.home.username}";
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

  systemd.user.services.cliphist-text = {
    Unit = {
      Description = "Store text clipboard history with cliphist";
      After = [ "graphical-session.target" ];
      PartOf = [ "graphical-session.target" ];
    };
    Service = {
      ExecStart = "${pkgs.wl-clipboard}/bin/wl-paste --type text --watch ${pkgs.cliphist}/bin/cliphist store";
      Restart = "always";
      RestartSec = 2;
    };
    Install.WantedBy = [ "graphical-session.target" ];
  };

  systemd.user.services.cliphist-image = {
    Unit = {
      Description = "Store image clipboard history with cliphist";
      After = [ "graphical-session.target" ];
      PartOf = [ "graphical-session.target" ];
    };
    Service = {
      ExecStart = "${pkgs.wl-clipboard}/bin/wl-paste --type image --watch ${pkgs.cliphist}/bin/cliphist store";
      Restart = "always";
      RestartSec = 2;
    };
    Install.WantedBy = [ "graphical-session.target" ];
  };

  # Configuration files
  # The old profile may still provide Mako's D-Bus activation file. Prevent it
  # from racing Quickshell for org.freedesktop.Notifications on shell restart.
  xdg.configFile."systemd/user/mako.service".source =
    config.lib.file.mkOutOfStoreSymlink "/dev/null";
  xdg.configFile."niri/config.kdl" = if isLaptop then {
    # Keep common shortcuts, but let laptop outputs choose their native modes.
    text = builtins.replaceStrings [ ''output "HDMI-A-2" {'' ''include "monitor.kdl"'' ]
      [ ''/-output "HDMI-A-2" {'' "// Laptop outputs are auto-detected." ] (builtins.readFile ./niri/config.kdl);
  } else {
    source = config.lib.file.mkOutOfStoreSymlink "/etc/nixos/niri/config.kdl";
  };
  xdg.configFile."quickshell/island".source =
    config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/Projects/quickshell-island";
  xdg.configFile."kitty/kitty.conf".source = ./kitty/kitty.conf;
  xdg.configFile."starship.toml".source = ./starship/starship.toml;
  xdg.configFile."nvim".source =
    config.lib.file.mkOutOfStoreSymlink "/etc/nixos/nvim";
  xdg.configFile."fastfetch/config.jsonc".source = ./fastfetch/config.jsonc;
  xdg.configFile."fastfetch/logo.txt".source = ./fastfetch/logo.txt;

  # Packages
  home.packages = with pkgs; [
    (writeShellScriptBin "quickshell-island" ''
      exec ${quickshell}/bin/qs -p ${lib.escapeShellArg "${config.xdg.configHome}/quickshell/island/src"} "$@"
    '')
    # Desktop / Wayland
    niri
    quickshell
    fuzzel
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
    flatpak

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
	vesktop
    steam
    pinta

    # CLI / Development
    git
    wget
    nodejs
	codex
	ollama
	# Nixpkgs 1d06008 ships opencode 2.2.5 with a stale Bun dependency hash.
	(opencode.overrideAttrs (old: {
	  node_modules = old.node_modules.overrideAttrs (_: {
	    outputHash = "sha256-prx9dX7kUvs/E3zopkaPk5LXh3xJAy5sZeum/W8L7cA=";
	  });
	}))
  ];
  
  services.flatpak = {
    enable = true;

    packages = [
      "org.vinegarhq.Sober"
    ];
  };
}
