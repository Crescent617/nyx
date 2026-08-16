{ config, pkgs, fonts, lib, ... }:

{
  home.pointerCursor = {
    gtk.enable = true;
    package = pkgs.bibata-cursors;
    name = "Bibata-Modern-Ice";
    size = 22;
  };

  programs.feh.enable = true; # 图片查看器

  # 剪贴板历史（Wayland data-control，配合 fuzzel 使用）
  # 快捷键（需在 COSMIC Settings -> Keyboard -> Custom Shortcuts 绑定 Super+V）：
  #   sh -c 'cliphist list | fuzzel --dmenu | cliphist decode | wl-copy'
  services.cliphist.enable = true;

  # fuzzel 启动器：默认窗口行列太少，调大；配色用 Catppuccin Mocha
  programs.fuzzel = {
    enable = true;
    settings = {
      main = {
        width = 60; # 窗口宽度（字符数）
        lines = 20; # 列表行数
        horizontal-pad = 24;
        vertical-pad = 16;
        inner-pad = 8;
      };
      border = {
        width = 2;
        radius = 8;
      };
      # Catppuccin Mocha (mauve accent)
      colors = {
        background = "1e1e2edd";
        text = "cdd6f4ff";
        prompt = "bac2deff";
        placeholder = "7f849cff";
        input = "cdd6f4ff";
        match = "cba6f7ff";
        selection = "585b70ff";
        selection-text = "cdd6f4ff";
        selection-match = "cba6f7ff";
        counter = "7f849cff";
        border = "cba6f7ff";
      };
    };
  };
}
