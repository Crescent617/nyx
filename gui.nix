{ config, pkgs, lib, ... }:

let cfg = config.nyx.gui;
in {
  options = { nyx.gui.enable = lib.mkEnableOption "Enable nyx configuration"; };
  config = lib.mkIf cfg.enable {
    services.xserver.enable = true;
    services.xserver.displayManager.gdm.enable = true;
    services.xserver.desktopManager.gnome.enable = true;
    services.xserver.videoDrivers = [ "nvidia" ];

    nixpkgs.config.allowUnfree = true;
    hardware.graphics.enable = true;
    hardware.nvidia = {
      modesetting.enable = true;
      open = true; # ✅ 显式指定使用开源驱动
      nvidiaSettings = true;
    };

    i18n.inputMethod.type.enabled = "fcitx5";
    i18n.inputMethod.fcitx5.addons = with pkgs; [ fcitx5-chinese-addons ];

    environment.systemPackages = with pkgs; [
      niri
      kitty
      waybar # 状态栏
    ];
  };
}
