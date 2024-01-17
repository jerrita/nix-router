{ config, pkgs, ... }:
{
    networking.hosts = {
        "192.168.5.5" = [ "helper" ];
        "192.168.5.6" = [ "cloud" ];
    };
}