{ config, pkgs, ... }:
{
    security.sudo.wheelNeedsPassword = false;
    users.users.clash = {
        uid = 1000;
        group = [ "clash" "wheel" ];
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
        "clash/scripts" = {
            source = ../static/clash/scripts;
            uid = 1000;
            group = "clash";
        };
        "clash/config.yaml" = {
            source = ../static/clash/config.yaml;
            uid = 1000;
            group = "clash";
            mode = "0600";
        };
        "clash/geoip.metadb" = {
            source = ../static/clash/geoip.metadb;
            uid = 1000;
            group = "clash";
            mode = "0600";
        };
    };

    systemd.services.clash = {
        wantedBy = [ "multi-user.target" ];
        wants = [ "network-online.target" ];
        after = [ "network-online.target" ];
        description = "Clash Service";
        path = [ pkgs.bash pkgs.iproute2 ];
        serviceConfig = {
            Type = "simple";
            User = "clash";
            Group = "clash";
            ExecStartPre = "/etc/clash/scripts/clash-pre";
            ExecStart = "${pkgs.mihomo}/bin/mihomo -d /etc/clash";
            ExecStop = "/etc/clash/scripts/clash-post";
            Restart = "on-failure";
            CapabilityBoundingSet="CAP_NET_ADMIN CAP_NET_BIND_SERVICE CAP_NET_RAW";
            AmbientCapabilities="CAP_NET_ADMIN CAP_NET_BIND_SERVICE CAP_NET_RAW";
        };
    };
    environment.systemPackages = [ pkgs.mihomo ];
}
