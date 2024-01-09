{ config, pkgs, ... }:
{
    services.miniupnpd = {
        enable = true;
        natpmp = true;
        externalInterface = "ppp0";
        internalIPs = [ "lan" ];
    };
}