{ config, pkgs, lib, ... }:
{
    services.miniupnpd = {
        enable = true;
        natpmp = true;
        externalInterface = "ppp0";
        internalIPs = [ "lan" ];
        # upnpTableName = "global";
    };
    systemd.services.miniupnpd.serviceConfig.wantedBy = lib.mkForce [ "dhcpcd.service" ];
}