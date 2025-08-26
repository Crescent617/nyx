{ config, lib, pkgs, ... }:

{
  imports = [
    ./home
  ];

  options = {
    nyx.gui.enable = lib.mkEnableOption "Enable nyx GUI configuration";
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
    boot.kernel.sysctl = {
      "kernel.sysrq" = 1;
    };

    environment.sessionVariables = {
      EDITOR = "nvim";
    };

    environment.systemPackages = with pkgs; [
      vim # Do not forget to add an editor to edit configuration.nix! The Nano editor is also installed by default.
      wget
      curl
      git
      tmux
      clang
      nodejs
      python3
      gnumake
      efibootmgr # reboot to another OS. e.g. sudo efibootmgr -n 0000 && reboot
      ntfs3g # for NTFS support
      uv # python package manager
      inetutils # for ping, traceroute, etc.
      pciutils
      busybox
      gcc
    ];

    programs.neovim.enable = true;

    services.openssh.enable = lib.mkDefault true;

    # nix-ld: Nix-based dynamic linker
    programs.nix-ld.enable = lib.mkDefault true;
    nixpkgs.config.packageOverrides = pkgs: {
      nur = import (builtins.fetchTarball "https://github.com/nix-community/NUR/archive/main.tar.gz") {
        inherit pkgs;
      };
      unstable = import
        (builtins.fetchTarball { url = "https://github.com/NixOS/nixpkgs/archive/nixos-unstable.tar.gz"; })
        {
          system = builtins.currentSystem;
        };
      zen-browser = (import (builtins.fetchTarball "https://github.com/youwen5/zen-browser-flake/archive/master.tar.gz") {
        inherit pkgs;
      }).default;
    };
  };
}
