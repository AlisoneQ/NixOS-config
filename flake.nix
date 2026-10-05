{

	description = "My rice ig";
	inputs = {
		nixpkgs.url = "nixpkgs/nixos-unstable";
		home-manager = {
			url = "github:nix-community/home-manager";
			inputs.nixpkgs.follows = "nixpkgs";
		};
		zen-browser = {
		  url = "github:0xc000022070/zen-browser-flake";
		  inputs.nixpkgs.follows = "nixpkgs";
		  inputs.home-manager.follows = "home-manager";
		};
	};

	outputs = { self, nixpkgs, home-manager, ... }@inputs: {
		nixosConfigurations.nixos = nixpkgs.lib.nixosSystem {
			system = "x86_64-linux";
			
		    specialArgs = { inherit inputs; };

			modules = [
				./configuration.nix
				home-manager.nixosModules.home-manager
				{
					home-manager = {
						useGlobalPkgs = true;
						useUserPackages = true;
						extraSpecialArgs = { inherit inputs; };
						users.alisoneq = import ./home.nix;
						backupFileExtension = "backup";
					};
				}
			];
		};
	};
}
