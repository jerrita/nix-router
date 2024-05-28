{ pkgs, lib }:
{
  systemd.network.networks."60-dhcp0" = {
    matchConfig.Name = "wan";
    networkConfig = {
      DHCP = "yes";
      IPv6AcceptRA = true;
    };
    dhcpV6Config = {
      WithoutRA = "solicit";
      DUIDType = "link-layer";
      RapidCommit = false;
    };
    ipv6AcceptRAConfig = {
      Token = "eui64";
      DHCPv6Client = "always";
    };
    linkConfig.RequiredForOnline = "routable";
  };
}
