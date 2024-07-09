{ config, pkgs, ... }:
{
  services.dnsmasq = {
    enable = true;
    settings = {
      conf-file = "/etc/dnsmasq.conf";
    };
  };
}
