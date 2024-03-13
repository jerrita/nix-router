{ config, pkgs, ... }:
{
    environment.etc."dnsmasq.d".source = ../static/dnsmasq;
    environment.etc."special.conf" = {
        source = ../static/special.conf;
        mode = "0644";
    };
    services.dnsmasq = {
        enable = true;
        settings = {
            interface = [ "lan" "lo" ];

            # Misc
            no-hosts = true;
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
            # we move this option to static/special.conf 
            # for updating dynamically by clash scripts
            server = [ "/in-addr.arpa/127.0.0.1#5353" ];
            conf-file = "/etc/special.conf";

            # DNS Scope
            port = 53;
        };
    };
}
