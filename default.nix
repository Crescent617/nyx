{ config, lib, pkgs, ... }:

{
  imports = [
    ./home
    ./gui
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
    nix.optimise.automatic = true;

    systemd.tmpfiles.rules = [
      "d /tmp 1777 root root 10d" # Clean /tmp every 10 days
    ];

    environment.sessionVariables = {
      EDITOR = "nvim";
      NIXPKGS_ALLOW_UNFREE = "1";
    };

    environment.systemPackages = with pkgs; [
      vim # Do not forget to add an editor to edit configuration.nix! The Nano editor is also installed by default.
      wget
      curl
      git
      tmux
      clang
      file
      nodejs
      python3
      gnumake
      efibootmgr # reboot to another OS. e.g. sudo efibootmgr -n 0000 && reboot
      ntfs3g # for NTFS support
      uv # python package manager
      inetutils # for ping, traceroute, etc.
      pciutils
      busybox
    ];

    programs.gnupg.agent = {
      enable = true;
      enableSSHSupport = true;
      pinentryPackage = pkgs.pinentry-curses; # TUI pinentry
    };

    programs.neovim.enable = true;

    services.udisks2.enable = lib.mkDefault true;
    services.openssh.enable = lib.mkDefault true;
    services.avahi.enable = lib.mkDefault true;
    services.tailscale.enable = true;

    virtualisation.podman.enable = lib.mkDefault true;

    # nix-ld: Nix-based dynamic linker
    programs.nix-ld.enable = lib.mkDefault true;

    networking.firewall.allowedTCPPorts = [ 53317 ]; # localsend use 53317 port
    networking.firewall.allowedUDPPorts = [ 53317 ];

    nixpkgs.config.packageOverrides = pkgs: {
      nur = import (builtins.fetchTarball "https://github.com/nix-community/NUR/archive/main.tar.gz") {
        inherit pkgs;
      };
      unstable = import
        (builtins.fetchTarball { url = "https://github.com/NixOS/nixpkgs/archive/nixos-unstable.tar.gz"; })
        {
          system = builtins.currentSystem;
        };
    };
  };
}
