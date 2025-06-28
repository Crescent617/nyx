{ config, lib, pkgs, ... }:

{
  imports = [
    ./home
    ./gui.nix
  ];

  options = {
    nyx.gui.enable = lib.mkEnableOption "Enable nyx GUI configuration";
  };

  config = {
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
    ];

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
  };
}
