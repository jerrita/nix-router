{ config, pkgs, ... }:
{
    systemd.services.nft-offload = {
        wantedBy = [  "network-online.target" ];
        wants = [ "network-online.target" ];
        after = [ "network-online.target" ];
        path = [ pkgs.nftables pkgs.bash ];
        serviceConfig = {
            ExecStart = "/etc/scripts/offload.sh";
            Restart = "on-failure";
        };
    };
}