{ config, lib, pkgs, ... }:
{

  imports = [ ./home ];
  nix.settings.substituters = [ "https://mirrors.tuna.tsinghua.edu.cn/nix-channels/store" ];
  time.timeZone = "Asia/Shanghai";
  networking.proxy.default = "http://archlinux.local:7890";
  networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

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
  ];

  services.openssh.enable = true;
  services.avahi.enable = true;
  # services.tailscale.enable = true;
}
