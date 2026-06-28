{
  description = "nyx NixOS module";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.11";
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager/release-25.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nur = {
      url = "github:nix-community/NUR";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    starsheep = {
      url = "github:Crescent617/starsheep";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };
    yomi-app = {
      url = "github:Crescent617/yomi";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };
    zen-browser = {
      url = "github:youwen5/zen-browser-flake";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };
  };

  outputs = { self, nixpkgs, nixpkgs-unstable, home-manager, nur, starsheep, zen-browser, yomi }:
    let
      system = "x86_64-linux";
      unstablePkgs = import nixpkgs-unstable {
        inherit system;
        config.allowUnfree = true;
      };
      overlay = final: prev: {
        unstable = unstablePkgs;
        zen-browser = zen-browser.packages.${system}.default;
        starsheep = starsheep.packages.${system}.default;
        yomi-app = yomi.packages.${system}.yomi-gui;
      };
    in
    {
      nixosModules.default = { config, pkgs, lib, ... }: {
        imports = [
          home-manager.nixosModules.default
          ./default.nix
        ];
        config.nixpkgs.overlays = [
          nur.overlays.default
          overlay
        ];
      };

      nixosModules.minimal = { config, pkgs, lib, ... }: {
        imports = [
          home-manager.nixosModules.default
          ./minimal.nix
        ];
        config.nixpkgs.overlays = [
          nur.overlays.default
          (final: prev: {
            unstable = unstablePkgs;
            starsheep = starsheep.packages.${system}.default;
          })
        ];
      };
    };
}
