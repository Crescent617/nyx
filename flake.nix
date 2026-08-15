{
  description = "nyx - My NixOS configuration library";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    home-manager = {
      url = "github:nix-community/home-manager/release-26.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nur.url = "github:nix-community/NUR";

    zen-browser.url = "github:youwen5/zen-browser-flake";

    starsheep.url = "github:Crescent617/starsheep";

    yomi.url = "github:Crescent617/yomi";
  };

  outputs =
    {
      self,
      nixpkgs,
      home-manager,
      nur,
      zen-browser,
      starsheep,
      yomi,
      ...
    }:
    let
      # Inject extra package sets so modules can use pkgs.unstable / pkgs.nur /
      # pkgs.zen-browser / pkgs.starsheep / pkgs.yomi-app without fetchTarball.
      extraPackages = final: prev: {
        unstable = import nixpkgs {
          inherit (final.stdenv.hostPlatform) system;
          config.allowUnfree = true;
        };
        zen-browser = zen-browser.packages.${final.stdenv.hostPlatform.system}.default;
        starsheep = starsheep.packages.${final.stdenv.hostPlatform.system}.default;
        yomi-app = yomi.packages.${final.stdenv.hostPlatform.system}.yomi-gui;
      };

      mkModule = module: {
        imports = [
          home-manager.nixosModules.home-manager
          module
        ];
        nixpkgs.overlays = [
          nur.overlays.default
          extraPackages
        ];
      };
    in
    {
      nixosModules.default = mkModule ./default.nix;
      nixosModules.minimal = mkModule ./minimal.nix;
    };
}
