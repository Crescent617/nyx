{ config, lib, pkgs, ... }:

with lib;

{
  config = {
    services.envfs.enable = lib.mkDefault true;
  };
}
