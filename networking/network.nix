{ config, pkgs, lib, ... }:
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
        address = [ "192.168.5.1/24" "fc00:cafe::1/48" ];
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
    };
  };
}
