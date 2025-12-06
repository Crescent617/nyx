{ config, pkgs, lib, ... }:
let
  home-manager = builtins.fetchTarball "https://github.com/nix-community/home-manager/archive/release-25.11.tar.gz";
  cfg = config.nyx;
in
{
  imports = [
    (import "${home-manager}/nixos")
  ];

  options = { };

  config = {
    # zsh configuration
    programs.zsh.enable = lib.mkDefault true;
    users.users."${cfg.userName}".shell = pkgs.zsh;

    # Home Manager configuration
    home-manager.useUserPackages = true;
    home-manager.useGlobalPkgs = true;
    home-manager.users."${cfg.userName}" = { pkgs, ... }: {
      imports = [ ./home.nix ] ++ lib.optional cfg.gui.enable ./home.gui.nix;
      # The state version is required and should stay at the version you
      # originally installed.
      home.stateVersion = cfg.stateVersion;
    };
  };
}
