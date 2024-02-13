{ config, pkgs, ... }:
let
    offloadScript = pkgs.writeScript "nft-offload" ''
        #!/usr/bin/env bash
        set -e

        if ! nft list flowtable inet global f &> /dev/null; then
            nft add flowtable inet global f { hook ingress priority filter\; devices = { lan, ppp0 }\; }
        fi

        if ! nft list chain inet global forward | grep -q flow; then
            nft insert rule inet global forward ip protocol { tcp, udp } flow offload @f
            nft insert rule inet global forward ip6 nexthdr { tcp, udp } flow offload @f
        fi
    '';
in {
    # nftables flow offload when network is online
    systemd.services.nft-offload = {
        wantedBy = [  "network-online.target" ];
        wants = [ "network-online.target" ];
        after = [ "network-online.target" ];
        path = [ pkgs.nftables pkgs.bash ];
        serviceConfig = {
            ExecStart = "${offloadScript}";
            Restart = "on-failure";
        };
    };
}