{ config, lib, pkgs, ... }:

with lib;

let
  configDir = "${./.}/etc";
in
{
  config = {
    virtualisation.oci-containers.containers = {
      searxng = {
        image = "searxng/searxng:latest";
        autoStart = true;
        ports = [ "8081:8080" ];
        volumes = [
          "${configDir}/searxng:/etc/searxng"
        ];
        environment = {
          BASE_URL = "http://localhost:8081/";
        };
      };
    };
  };
}
