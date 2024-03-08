{ config, pkgs, ... }:
{
    imports = [
        ./dnsmasq.nix
        ./smartdns.nix
        ./order.nix
    ];

    services.timesyncd.servers = [
        "ntp.aliyun.com"
        "ntp1.aliyun.com"
        "ntp2.aliyun.com"
        "ntp3.aliyun.com"
        "ntp4.aliyun.com"
    ];

    networking = {
        firewall.enable = false;
        nftables = {
            enable = true;
            rulesetFile = ./firewall.nft;
            preCheckRuleset = ''
                sed -i 's/skuid clash/skgid nogroup/g' ruleset.conf
            '';
            flattenRulesetFile = true;
            # https://discourse.nixos.org/t/nftables-could-not-process-rule-no-such-file-or-directory/33031
            # checkRuleset = false;
        };

        interfaces = {
            wan.useDHCP = true;
            lan = {
                ipv4.addresses = [{
                    address = "192.168.5.1";
                    prefixLength = 24;
                }];
            };
        };

        dhcpcd = {
            enable = true;
            allowInterfaces = [ "ppp0" ];
            extraConfig = ''
                # don't touch our DNS settings
                nohook resolv.conf

                # generate a RFC 4361 complient DHCP ID
                duid

                # We don't want to expose our hw addr from the router to the internet,
                # so we generate a RFC7217 address.
                slaac private

                option rapid_commit
                option domain_name_servers, domain_name, domain_search, host_name
                option classless_static_routes
                option interface_mtu
                require dhcp_server_identifier

                # we only want to handle IPv6 with dhcpcd, the IPv4 is still done
                # through pppd daemon
                noipv6rs
                ipv6only

                # settings for the interface
                interface ppp0
                    ipv6rs               # router advertisement solicitaion
                    iaid 1               # interface association ID
                    ia_pd 2 lan/0        # request a PD and assign to interface
            '';
        };
    };

    services.vnstat.enable = true;
}