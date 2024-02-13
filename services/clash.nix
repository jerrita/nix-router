{ config, pkgs, ... }:
{
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
            ExecStartPre = "/etc/scripts/clash-pre";
            ExecStart = "${pkgs.clash-meta}/bin/clash-meta -d /etc/clash";
            ExecStop = "/etc/scripts/clash-post";
            Restart = "on-failure";
            CapabilityBoundingSet="CAP_NET_ADMIN CAP_NET_BIND_SERVICE CAP_NET_RAW";
            AmbientCapabilities="CAP_NET_ADMIN CAP_NET_BIND_SERVICE CAP_NET_RAW";
        };
    };
    environment.systemPackages = [ pkgs.clash-meta ];
}
