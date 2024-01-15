{ config, pkgs, ... }:
{
    systemd.services.nftables = {
        wants = lib.mkForce [ "network.target" ];
        before = lib.mkForce [ ];
        after = [ "network.target" ];
    };
    systemd.services.dhcpcd = {
        wants = [ "network-online.target" ];
        after = [ "network-online.target" ];
        serviceConfig = {
            ExecStartPre = "${pkgs.coreutils}/bin/sleep 5";
        };
    };
}