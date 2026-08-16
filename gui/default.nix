{ config, pkgs, lib, font, ... }:

let
  cfg = config.nyx.gui;
  userName = config.nyx.userName;
  preferUnstable = name: if pkgs ? unstable then pkgs.unstable."${name}" else pkgs."${name}";
in
{
  imports = [ ./virt.nix ];

  config = lib.mkIf cfg.enable {

    environment.sessionVariables = {
      NIXOS_OZONE_WL = "1";
    };

    # services.xserver.enable = true;
    services.xserver.videoDrivers = [ "nvidia" ];

    # services.displayManager.ly.enable = true;
    # services.xserver.displayManager.gdm.enable = true;
    # COSMIC 官方登录界面（自动管理 greetd，会话菜单可选 niri / COSMIC）
    services.displayManager.cosmic-greeter.enable = true;

    # COSMIC 桌面环境（System76，登录界面可选）
    services.desktopManager.cosmic.enable = true;

    programs.niri.enable = true; # 窗口管理器

    nixpkgs.config.allowUnfree = true;
    hardware.graphics.enable = true;
    hardware.nvidia = {
      modesetting.enable = true;
      open = true;
      nvidiaSettings = true;
      powerManagement.enable = true; # 修复suspend/hibernate后黑屏问题
    };

    i18n.extraLocales = [ "zh_CN.UTF-8/UTF-8" ];
    i18n.inputMethod = {
      enable = true;
      type = "fcitx5";
      fcitx5 = {
        addons = with pkgs; [
          fcitx5-gtk
          qt6Packages.fcitx5-chinese-addons
          qt6Packages.fcitx5-configtool # 图形配置工具
        ];
        waylandFrontend = true;
      };
    };
    xdg.mime = {
      enable = true;
      defaultApplications = {
        "inode/directory" = "thunar.desktop";
      };
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

    programs.firefox.enable = true;
    programs.thunar.enable = true;

    # ToDesk 远程桌面（官方模块：自动装包、创建 /var/lib/todesk、运行 todeskd 守护进程）
    services.todesk.enable = true;

    services.sunshine = {
      enable = true;
      autoStart = true;
      capSysAdmin = true; # 如果你使用 Wayland，这通常是必须的
      openFirewall = true; # 自动在防火墙中打开 47984-48010 等端口
    };
    # 2. 强制 udev 规则 (这是修复 sunshine Permission Denied 的核心)
    services.udev.extraRules = ''
      KERNEL=="uinput", MODE="0660", GROUP="input", OPTIONS+="static_node=uinput"
    '';

    services.gvfs.enable = true; # 支持自动挂载、缩略图等
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
      (preferUnstable "ghostty")
      mako # 通知管理器
      noti # 通知发送器
      appimage-run # A tool for running AppImage files
      vulkan-tools # Vulkan command-line utilities

      nvtopPackages.full
      pavucontrol # PulseAudio gui音量控制
      pamixer # PulseAudio 命令行控制音量（volume 模块用）

      xwayland-satellite # XWayland 兼容层
      waybar # 状态栏
      swaybg # 背景设置
      wl-clipboard # 用于在 Wayland 上复制粘贴
      wlsunset # 夜间模式
      (preferUnstable "zed-editor")
      localsend
      postman

      # cherry-studio # 暂时移除：依赖的 electron-40 已 EOL，等升级后再加回
      zen-browser
      vivaldi
      vscode
      wechat
      vlc

      libreoffice
      (preferUnstable "feishu")
      dbeaver-bin

      thunderbird
      obs-studio # 屏幕录制
      godot
      unityhub
      remmina
      # (preferUnstable "nomachine-client") # 暂时移除：官方下架了 9.5.7 安装包，等 nixpkgs 更新后再加回
      moonlight-qt # Moonlight 客户端，配合 Sunshine 串流

      nur.repos.xddxdd.baidunetdisk
      yomi-app
    ];
  };
}
