{ config, pkgs, ... }:
{
    environment.etc."dnsmasq.d".source = ../static/dnsmasq;
    services.dnsmasq = {
        enable = true;
        settings = {
            interface = [ "lan" "lo" ];

            # Misc
            domain-needed = true;
            read-ethers = true;
            expand-hosts = true;
            local-service = true;
            edns-packet-max = "1232";
            no-dhcp-interface = "ppp0";

            # DHCP Scope
            log-dhcp = true;
            enable-ra = true;
            local = "/lan/";
            domain = "lan";
            dhcp-range = [ 
                "192.168.5.20,192.168.5.250,12h"
                "::,constructor:lan,ra-only,slaac"
            ];
            dhcp-option = [
                "3,192.168.5.1"   # Gateway
                "6,192.168.5.1"   # DNS
                "119,lan"         # search domain
            ];

            # acc -> smartdns; others -> clash fake-ip
            server = [ 
                "127.0.0.1#5355"
                "/in-addr.arpa/127.0.0.1#5353"  # mdns lookup
            ];

            conf-dir = "/etc/dnsmasq.d";
            cache-size = 0;

            # DNS Scope
            port = 53;
        };
    };
}
