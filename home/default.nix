{ config, pkgs, lib, ... }:
let
  home-manager = builtins.fetchTarball "https://github.com/nix-community/home-manager/archive/release-25.05.tar.gz";
  cfg = config.nyx;
in
{
  imports = [
    (import "${home-manager}/nixos")
  ];

  options = {
    nyx.userName = lib.mkOption {
      type = lib.types.str;
      description = "The name of the user to create.";
    };
    nyx.stateVersion = lib.mkOption {
      type = lib.types.str;
      description = "The state version of the home-manager configuration.";
    };
  };

  config = {
    # zsh configuration
    programs.zsh.enable = lib.mkDefault true;
    users.users."${cfg.userName}".shell = pkgs.zsh;

    # Home Manager configuration
    home-manager.useUserPackages = true;
    home-manager.useGlobalPkgs = true;
    home-manager.users."${cfg.userName}" = { pkgs, ... }: {
      imports = [ ./home.nix ];
      # The state version is required and should stay at the version you
      # originally installed.
      home.stateVersion = cfg.stateVersion;
    };
  };
}
