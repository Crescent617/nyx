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
    ];

    programs.neovim.enable = true;

    services.openssh.enable = lib.mkDefault true;

    # nix-ld: Nix-based dynamic linker
    programs.nix-ld.enable = lib.mkDefault true;
  };
}
