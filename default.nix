{ config, lib, pkgs, ... }:

{
  imports = [
    ./home
    ./gui.nix # disable gui by default
  ];

  config = {
    nix.settings.substituters =
      [ "https://mirrors.tuna.tsinghua.edu.cn/nix-channels/store" ];

    environment.systemPackages = with pkgs; [
      vim # Do not forget to add an editor to edit configuration.nix! The Nano editor is also installed by default.
      wget
      curl
      git
      tmux
      neovim
      clang
      nodejs
      python3
      gnumake
      podman
    ];

    services.openssh.enable = lib.mkDefault true;
    services.avahi.enable = true;
    # services.tailscale.enable = true;

    # nix-ld: Nix-based dynamic linker
    programs.nix-ld.enable = true;
  };
}
