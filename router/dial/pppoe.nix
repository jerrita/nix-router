{ config, pkgs, ... }:
{
  services.pppd = {
    enable = true;
    peers = {
      telecom = {
        autostart = true;
        enable = true;
        config = ''
          plugin pppoe.so wan

          nic-wan
                
          name ""
          password ""

          persist
          maxfail 0
          holdoff 5

          +ipv6
          noipdefault
          defaultroute
          usepeerdns
          replacedefaultroute
        '';
      };
    };
  };
  systemd.network.networks."60-ppp0" = {
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
}
