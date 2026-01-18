# Example: Using nyx as a submodule in your flake.nix
# Save this as /etc/nixos/flake.nix and customize as needed

{
  description = "My NixOS configuration with nyx submodule";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    # Reference nyx as a submodule (path or GitHub URL)
    nyx.url = "path:/etc/nixos/nyx";  # For local development
    # nyx.url = "github:your-username/nyx";  # For GitHub hosting

    # Home Manager (required for nyx's home-manager integration)
    home-manager = {
      url = "github:nix-community/home-manager/release-25.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, nyx, home-manager, ... }:
    let
      system = "x86_64-linux";
    in
    {
      nixosConfigurations.your-hostname = nixpkgs.lib.nixosSystem {
        inherit system;
        modules = [
          # Your hardware configuration (required)
          ./hardware-configuration.nix

          # Enable Home Manager (required for nyx's home-manager integration)
          home-manager.nixosModules.home-manager

          # Include nyx configuration (includes both system and home-manager settings)
          nyx.nixosModules.default  # Full configuration with GUI
          # nyx.nixosModules.minimal  # Minimal configuration without GUI

          # Your custom settings
          ({ config, pkgs, ... }: {
            # Required: Set your username (used by both system and home-manager)
            nyx.userName = "your-username";

            # Optional: Customize nyx settings
            nyx.gui.enable = true;  # Enable GUI (default in full config)
            nyx.stateVersion = "25.05";

            # System-specific settings
            networking.hostName = "your-hostname";

            # Bootloader configuration
            boot.loader.systemd-boot.enable = true;
            boot.loader.efi.canTouchEfiVariables = true;

            # File systems configuration (example - replace with your actual config)
            # fileSystems."/" = {
            #   device = "/dev/disk/by-uuid/your-root-partition-uuid";
            #   fsType = "ext4";
            # };

            # User configuration (required)
            users.users.your-username = {
              isNormalUser = true;
              description = "Your Name";
              extraGroups = [ "wheel" "networkmanager" ];
              # Home Manager will automatically configure the shell and other settings
            };

            # System state version
            system.stateVersion = "25.05";
          })
        ];
      };
    };
}
