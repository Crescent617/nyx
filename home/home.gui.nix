{ config, pkgs, fonts, lib, ... }:

{
  home.pointerCursor = {
    gtk.enable = true;
    package = pkgs.bibata-cursors;
    name = "Bibata-Modern-Ice";
    size = 22;
  };

  programs.feh.enable = true; # 图片查看器
}
