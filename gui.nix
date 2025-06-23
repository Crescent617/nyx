{ config, pkgs, lib, ... }:

let cfg = config.nyx.gui;
in
{
  options = { nyx.gui.enable = lib.mkEnableOption "Enable nyx configuration"; };
  config = lib.mkIf cfg.enable {
    environment.sessionVariables.NIXOS_OZONE_WL = "1";

    # services.xserver.enable = false;
    services.xserver.videoDrivers = [ "nvidia" ];

    services.displayManager.ly.enable = true;
    programs.niri.enable = true; # 窗口管理器

    nixpkgs.config.allowUnfree = true;
    hardware.graphics.enable = true;
    hardware.nvidia = {
      modesetting.enable = true;
      open = true; # ✅ 显式指定使用开源驱动
      nvidiaSettings = true;
    };

    i18n.inputMethod.type.enabled = "fcitx5";
    i18n.inputMethod.fcitx5.addons = with pkgs; [ 
      fcitx5-chinese-addons
      fcitx5-rime
      fcitx5-qt
      fcitx5-gtk
    ];

    programs.firefox.enable = true;
    environment.systemPackages = with pkgs; [
      # Fonts
      nerd-fonts.jetbrains-mono
      nerd-fonts.caskaydia-cove
      maple-mono.truetype # Maple Mono (Ligature TTF unhinted)
      maple-mono.NF-CN-unhinted # Maple Mono NF CN (Ligature unhinted)

      # Apps
      kitty
      fuzzel # 启动器
      waybar # 状态栏
    ];
  };
}
