{ inputs, config, pkgs, ... }:

{
	imports = [
	    inputs.zen-browser.homeModules.beta
	    inputs.noctalia.homeModules.default
	];

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

	programs.noctalia = {
	  enable = true;
	};

	home.username = "alisoneq";
	home.homeDirectory = "/home/alisoneq";
	home.stateVersion = "25.11";

	programs.home-manager.enable = true;

	xdg.configFile."niri/config.kdl".source = ./niri/config.kdl;
	xdg.configFile."kitty/kitty.conf".source = ./kitty/kitty.conf;
	xdg.configFile."starship.toml".source = ./starship/starship.toml;
	xdg.configFile."nvim".source = config.lib.file.mkOutOfStoreSymlink "/etc/nixos/nvim";

	home.packages = with pkgs; [
		fuzzel
		neovim
		cliphist
		firefox
		discord
		steam
		micro
		xwayland-satellite
	];
}
