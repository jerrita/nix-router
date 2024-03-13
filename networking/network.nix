{ config, pkgs, ... }:
{
    services.resolved.enable = false;
    systemd.network = {
        enable = true;
        networks = {
            "30-wan" = {
                matchConfig.Name = "wan";
                linkConfig = {
                    RequiredForOnline = "carrier";
                };
                networkConfig.LinkLocalAddressing = "no";
            };
            "30-lan" = {
                matchConfig.Name = "lan";
                address = [ "192.168.5.1/24" ];
                networkConfig = {
                    ConfigureWithoutCarrier = true;
                    DHCPPrefixDelegation = true;
                    IPv6AcceptRA = false;
                    IPv6SendRA = true;
                };
                dhcpPrefixDelegationConfig = {
                    SubnetId = "64";
                };
                linkConfig = {
                    RequiredForOnline = "routable";
                };
            };
            "60-ppp0" = {
                matchConfig.Type = "ppp";
                networkConfig = {
                    IPv6AcceptRA = true;
                    DHCP = "ipv6";
                    KeepConfiguration = true;
                };
                dhcpV6Config = {
                    WithoutRA = "solicit";
                    PrefixDelegationHint = "::/56";
                };
                ipv6SendRAConfig = {
                    Managed = true;
                };
                linkConfig.RequiredForOnline = "routable";
            };
        };
    };
}