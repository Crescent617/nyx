{ config, pkgs, lib, ... }:

let cfg = config.nyx.gui;
in
{
  options = { nyx.gui.enable = lib.mkEnableOption "Enable nyx configuration"; };
  config = lib.mkIf cfg.enable {
    environment.sessionVariables.NIXOS_OZONE_WL = "1";

    services.xserver.enable = false;
    services.xserver.videoDrivers = [ "nvidia" ];

    programs.ly.enable = true; # 登录管理器
    programs.niri.enable = true; # 窗口管理器

    nixpkgs.config.allowUnfree = true;
    hardware.graphics.enable = true;
    hardware.nvidia = {
      modesetting.enable = true;
      # open = true; # ✅ 显式指定使用开源驱动
      nvidiaSettings = true;
    };

    i18n.inputMethod.type.enabled = "fcitx5";
    i18n.inputMethod.fcitx5.addons = with pkgs; [ fcitx5-chinese-addons ];

    environment.systemPackages = with pkgs; [
      kitty
      fuzzel # 启动器
      waybar # 状态栏
    ];
  };
}
