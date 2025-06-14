{ config, pkgs, lib, ... }:

let
  home-manager = builtins.fetchTarball https://github.com/nix-community/home-manager/archive/release-25.05.tar.gz;
  userName = "hrli";
in
{
  imports =
    [
      (import "${home-manager}/nixos")
      # ./gui.nix # disable gui by default
    ];

  programs.zsh.enable = true;

  users.users."${userName}" = {
    isNormalUser = true;
    extraGroups = [ "wheel" ]; # Enable ‘sudo’ for the user.
    shell = pkgs.zsh;
    initialPassword = "pw123";
  };

  home-manager.useUserPackages = true;
  home-manager.useGlobalPkgs = true;

  home-manager.users."${userName}" = { pkgs, ... }: {

    imports = [ ./home.nix ];
    # The state version is required and should stay at the version you
    # originally installed.
    home.stateVersion = "25.05";
  };
}
