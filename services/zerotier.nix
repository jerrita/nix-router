{ config, pkgs, ... }:
{
    services.zerotierone = {
        enable = false;
        joinNetworks = [ "" ];
    };
}