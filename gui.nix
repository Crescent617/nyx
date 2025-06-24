{ config, pkgs, lib, font, ... }:

let cfg = config.nyx.gui;
in
{
  options = { nyx.gui.enable = lib.mkEnableOption "Enable nyx configuration"; };
  config = lib.mkIf cfg.enable {
    environment.sessionVariables.NIXOS_OZONE_WL = "1";

    # services.xserver.enable = true;
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

    # 启用 fcitx5 输入法
    i18n.inputMethod = {
      type = "fcitx5";
      enable = true;
      fcitx5.addons = with pkgs; [
        fcitx5-chinese-addons
        fcitx5-configtool # 图形配置工具
        fcitx5-gtk
        fcitx5-rime
        fcitx5-nord
      ];
    };

    # 安装中文字体
    fonts.packages = with pkgs; [
      noto-fonts
      noto-fonts-cjk-sans
      wqy_zenhei
      wqy_microhei
      nerd-fonts.jetbrains-mono
      nerd-fonts.caskaydia-cove
      maple-mono.truetype # Maple Mono (Ligature TTF unhinted)
      maple-mono.NF-CN-unhinted # Maple Mono NF CN (Ligature unhinted)
    ];

    environment.sessionVariables = {
      GTK_IM_MODULE = "fcitx";
      QT_IM_MODULE = "fcitx";
      XMODIFIERS = "@im=fcitx";
    };

    # Browser
    programs.firefox.enable = true;
    # Audio
    services.pipewire = {
      enable = true;
      pulse.enable = true;
      alsa.enable = true;
      alsa.support32Bit = true;
    };

    security.rtkit.enable = true;
    environment.systemPackages = with pkgs; [
      clipse # 剪贴板管理器
      fuzzel # 启动器
      kitty
      mako # 通知管理器
      noti # 通知发送器
      pavucontrol # 音量控制
      pamixer # 控制音量（volume 模块用）
      swaybg # 背景设置
      waybar # 状态栏
      wl-clipboard # 用于在 Wayland 上复制粘贴
      wlsunset # 夜间模式
      xwayland-satellite # XWayland 支持
    ];
  };
}
