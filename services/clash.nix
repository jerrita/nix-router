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
            ExecStartPre = "+/etc/scripts/clash-pre";
            ExecStart = "${pkgs.mihomo}/bin/mihomo -d /etc/clash";
            ExecStop = "+/etc/scripts/clash-post";
            Restart = "on-failure";
            CapabilityBoundingSet="CAP_NET_ADMIN CAP_NET_BIND_SERVICE CAP_NET_RAW";
            AmbientCapabilities="CAP_NET_ADMIN CAP_NET_BIND_SERVICE CAP_NET_RAW";
        };
    };
    environment.systemPackages = [ pkgs.mihomo ];
}
