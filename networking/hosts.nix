{ config, pkgs, ... }:
{
    networking.hosts = {
        "192.168.5.1" = [ "router" ];
        "192.168.5.6" = [ "cloud" ];
    };
}
