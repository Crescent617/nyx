{ config, pkgs, lib, ... }:
let
  cfg = config.nyx;
in
{
  options = { };

  config = {
    users.users."${cfg.userName}" = {
      extraGroups = [ "input" "video" ];
      shell = pkgs.zsh;
    };

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
