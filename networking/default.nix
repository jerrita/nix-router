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

  networking = {
    firewall.enable = false;
    useDHCP = false;
    nftables = {
      enable = true;
      rulesetFile = ./firewall.nft;
      # preCheckRuleset = ''
      #     sed -i 's/skuid clash/skgid nogroup/g' ruleset.conf
      # '';
      flattenRulesetFile = true;
    };
  };

  services.vnstat.enable = true;
}

