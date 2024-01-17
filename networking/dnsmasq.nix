{ config, pkgs, ... }:
{
    services.dnsmasq = {
        enable = true;
        settings = {
            interface = [ "lan" "lo" ];

            # DHCP Scope
            log-dhcp = true;
            enable-ra = true;
            dhcp-range = [ 
                "192.168.5.10,192.168.5.250,12h"
                "::,constructor:lan,ra-only,slaac"
            ];
            dhcp-option = [
                "3,192.168.5.1"   # Gateway
                "6,192.168.5.1"   # DNS
                "119,lan"         # search domain
            ];

            # acc -> smartdns; others -> clash fake-ip
            server = [ "127.0.0.1#5355" ];
            conf-dir = "/etc/dnsmasq.d";
            cache-size = 0;

            # DNS Scope
            port = 53;
        };
    };
}