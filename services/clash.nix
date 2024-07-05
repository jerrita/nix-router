{ config, pkgs, ... }:
{
    users.users.clash = {
        uid = 1000;
        group = "clash";
        isNormalUser = true;
    };
    users.groups.clash = {};
    environment.etc = {
        "clash/yacd" = {
            source = pkgs.fetchzip {
                url = "https://github.com/haishanh/yacd/archive/refs/heads/gh-pages.zip";
                hash = "sha256-SaVsY2kGd+v6mmjwXAHSgRBDBYCxpWDYFysCUPDZjlE=";
            };
            uid = 1000;
            group = "clash";
        };
    };

    systemd.services.clash = {
        wantedBy = [ "multi-user.target" ];
        wants = [ "network-online.target" ];
        after = [ "dnsmasq.service" ];
        description = "Clash Service";
        path = [ pkgs.bash ];
        serviceConfig = {
            Type = "simple";
            User = "clash";
            Group = "clash";
            # ExecStartPre = "+/etc/clash/scripts/clash-pre";
            ExecStartPre = "+${pkgs.writeScript "preStart" ''#!/usr/bin/env bash
                mkdir -p /etc/clash
                chown -R clash:clash /etc/clash
                sed -i 's/server=127.0.0.1#5353/server=127.0.0.1#5355/g' /etc/dnsmasq.conf
                systemctl restart dnsmasq
            ''}";
            ExecStart = "${pkgs.mihomo}/bin/mihomo -d /etc/clash";
            ExecStopPost = "+${pkgs.writeScript "postStop" ''#!/usr/bin/env bash
                sed -i 's/server=127.0.0.1#5355/server=127.0.0.1#5353/g' /etc/dnsmasq.conf
                systemctl restart dnsmasq
            ''}";
            # ExecStop = "+/etc/clash/scripts/clash-post";
            Restart = "on-failure";
            CapabilityBoundingSet="CAP_NET_ADMIN CAP_NET_BIND_SERVICE CAP_NET_RAW";
            AmbientCapabilities="CAP_NET_ADMIN CAP_NET_BIND_SERVICE CAP_NET_RAW";
        };
    };
    environment.systemPackages = [ pkgs.mihomo ];
}
