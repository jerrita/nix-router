{ config, pkgs, ... }:
{
  imports = [
    ./dnsmasq.nix
    ./smartdns.nix
    ./network.nix
  ];

  services.timesyncd.servers = [
    "ntp.aliyun.com"
    "ntp1.aliyun.com"
    "ntp2.aliyun.com"
    "ntp3.aliyun.com"
    "ntp4.aliyun.com"
  ];

  networking.timeServers = [
    "ntp.aliyun.com"
    "ntp1.aliyun.com"
    "ntp2.aliyun.com"
    "ntp3.aliyun.com"
    "ntp4.aliyun.com"
    "ntp5.aliyun.com"
    "ntp6.aliyun.com"
    "ntp7.aliyun.com"
  ];

  networking = {
    firewall.enable = false;
    useDHCP = false;
    nftables = {
      enable = true;
      rules = ''
        include "/etc/firewall.nft";
      '';
    };
  };

  services.vnstat.enable = true;
}
