{
  description = "Nyx NixOS configuration - Submodule for NixOS and Home Manager";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    home-manager = {
      url = "github:nix-community/home-manager/release-25.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";

    nur.url = "github:nix-community/NUR";

    zen-browser-flake.url = "github:youwen5/zen-browser-flake";

    starsheep.url = "github:Crescent617/starsheep";
  };

  outputs = { self, nixpkgs, home-manager, nixpkgs-unstable, nur, zen-browser-flake, starsheep, ... }:
    let
      # Supported systems
      supportedSystems = [ "x86_64-linux" "aarch64-linux" ];

      # Use nixpkgs.lib
      lib = nixpkgs.lib;

      # Helper function to generate overlays
      makeOverlays = system: [
        (final: prev: {
          nur = import nur {
            pkgs = prev;
          };
          unstable = nixpkgs-unstable.legacyPackages.${prev.system};
          zen-browser = zen-browser-flake.packages.${prev.system}.default;
          starsheep = starsheep.packages.${prev.system}.default;
        })
      ];

    in
    {
      # Home Manager modules - for standalone use or import
      # Usage: home-manager.users.your-user.imports = [ nyx.homeModules.default ]
      homeModules = {
        # Full home configuration (with GUI tools)
        default = { config, lib, pkgs, ... }: {
          imports = [
            ./home/home.nix
            ./home/home.gui.nix
          ];
        };

        # Minimal home configuration (no GUI tools)
        minimal = { config, lib, pkgs, ... }: {
          imports = [ ./home/home.nix ];
        };
      };

      # NixOS modules - for use as submodule in your flake.nix
      # Usage: modules = [ home-manager.nixosModules.home-manager nyx.nixosModules.default ]
      nixosModules = rec {
        # Full configuration with automatic Home Manager integration
        default = { config, ... }: {
          imports = [
            # Include nyx system configuration
            ./default.nix
          ];

          # Auto-configure Home Manager and overlays if available
          config = lib.mkMerge [
            # Apply package overlays
            ({ nixpkgs.overlays = makeOverlays config.nixpkgs.hostPlatform.system or "x86_64-linux"; })

            # Configure Home Manager if the module is loaded
            (lib.mkIf (config ? home-manager) {
              home-manager.useGlobalPkgs = lib.mkDefault true;
              home-manager.useUserPackages = lib.mkDefault true;

              # Configure for the nyx user
              home-manager.users.${config.nyx.userName or "hrli"} = { config, ... }: {
                imports = [
                  ./home/home.nix
                  ./home/home.gui.nix
                ];

                home = {
                  stateVersion = config.nyx.stateVersion or "25.05";
                  username = config.nyx.userName or "hrli";
                  homeDirectory = lib.mkDefault "/home/${config.nyx.userName or "hrli"}";
                };
              };
            })
          ];
        };

        # Minimal configuration (no GUI)
        minimal = { config, ... }: {
          imports = [ ./minimal.nix ];

          # Auto-configure Home Manager and overlays if available
          config = lib.mkMerge [
            # Apply package overlays
            ({ nixpkgs.overlays = makeOverlays config.nixpkgs.hostPlatform.system or "x86_64-linux"; })

            # Configure Home Manager if the module is loaded
            (lib.mkIf (config ? home-manager) {
              home-manager.useGlobalPkgs = lib.mkDefault true;
              home-manager.useUserPackages = lib.mkDefault true;

              # Configure for the nyx user
              home-manager.users.${config.nyx.userName or "hrli"} = { config, ... }: {
                imports = [ ./home/home.nix ];

                home = {
                  stateVersion = config.nyx.stateVersion or "25.05";
                  username = config.nyx.userName or "hrli";
                  homeDirectory = lib.mkDefault "/home/${config.nyx.userName or "hrli"}";
                };
              };
            })
          ];
        };
      };

      # Development shells - for working on nyx itself
      devShells = lib.genAttrs supportedSystems (system:
        let
          pkgs = nixpkgs.legacyPackages.${system};
        in
        {
          default = pkgs.mkShell {
            buildInputs = with pkgs; [
              git
              nixpkgs-fmt
            ];
          };
        }
      );
    };
}
