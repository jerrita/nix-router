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
        path = [ pkgs.bash ];
        serviceConfig = {
            Type = "simple";
            User = "clash";
            Group = "clash";
            ExecStart = "${pkgs.mihomo}/bin/mihomo -d /etc/clash";
            Restart = "on-failure";
            CapabilityBoundingSet="CAP_NET_ADMIN CAP_NET_BIND_SERVICE CAP_NET_RAW";
            AmbientCapabilities="CAP_NET_ADMIN CAP_NET_BIND_SERVICE CAP_NET_RAW";
        };
        preStart = ''
            mkdir -p /etc/clash
            chown -R clash:clash /etc/clash
            sed -i 's/server=127.0.0.1#5353/server=127.0.0.1#5355/g' /etc/special.conf
            systemctl restart dnsmasq
        '';
        postStop = ''
            sed -i 's/server=127.0.0.1#5355/server=127.0.0.1#5353/g' /etc/special.conf
            systemctl restart dnsmasq
        '';
    };
    environment.systemPackages = [ pkgs.mihomo ];
}