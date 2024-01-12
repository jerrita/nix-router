{ config, pkgs, ... }:
{
    services.miniupnpd = {
        enable = true;
        natpmp = true;
        externalInterface = "ppp0";
        internalIPs = [ "lan" ];
    };
    systemd.services.miniupnpd.serviceConfig.ExecStartPre = ''
        ${pkgs.coreutils}/bin/sleep 10
    '';
}