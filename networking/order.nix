{ config, pkgs, lib, ... }:
{
    systemd.services.nftables = {
        wants = lib.mkForce [ "network.target" ];
        before = lib.mkForce [ ];
        after = [ "network.target" ];
    };
    systemd.services.dhcpcd = {
        wants = lib.mkForce [ "network-online.target" ];
        after = lib.mkForce [ "network-online.target" ];
        before = lib.mkForce [ ];
        serviceConfig = {
            ExecStartPre = "${pkgs.coreutils}/bin/sleep 5";
        };
    };
}