{
  config,
  pkgs,
  ...
}: let
  settings = builtins.fromJSON (builtins.readFile ../static/sing.json);
  extraSettings = {
    log.level = "warn";
    dns = {
      servers = [
        {
          tag = "local";
          address = "127.0.0.1:5353";
          detour = "direct";
          address_resolver = "bootstrap";
        }
        {
          tag = "bootstrap";
          address = "223.5.5.5";
          detour = "direct";
        }
        {
          tag = "remote";
          address = "fakeip";
        }
        {
          tag = "nxdomain";
          address = "rcode://name_error";
        }
      ];
      rules = [
        {
          geosite = "category-ads-all";
          server = "nxdomain";
          disable_cache = true;
        }
        {
          inbound = "dns-in";
          server = "remote";
        }
      ];
      fakeip = {
        enabled = true;
        inet4_range = "198.18.0.0/15";
        inet6_range = "fc00::/18";
      };
      strategy = "prefer_ipv6";
      independent_cache = true;
    };
    inbounds = [
      {
        type = "direct";
        tag = "dns-in";
        network = "udp";
        listen = "::";
        listen_port = 5355;
      }
      {
        type = "tun";
        inet4_address = "172.19.0.1/30";
        gso = true;
        auto_route = true;
        inet4_route_address = [
          "198.18.0.0/15"
          "8.8.8.8/32"
          "1.1.1.1/32"
          "91.108.4.0/22"
          "91.108.8.0/22"
          "91.108.12.0/22"
          "91.108.16.0/22"
          "91.108.20.0/22"
          "91.108.56.0/22"
          "91.108.192.0/22"
          "149.154.160.0/20"
          "185.76.151.0/24"
        ];
        inet6_route_address = [
          "fc00::/18"
          "2001:b28:f23d::/48"
          "2001:b28:f23f::/48"
          "2001:67c:4e8::/48"
          "2001:b28:f23c::/48"
          "2a0a:f280::/32"
        ];
      }
    ];
    route = {
      rules = [
        {
          inbound = "dns-in";
          outbound = "dns-out";
        }
        {
          geosite = "category-ads-all";
          outbound = "block";
        }
      ];
      default_interface = "ppp0";
    };
    experimental = {
      cache_file = {
        enabled = true;
        store_fakeip = true;
      };
      clash_api = {
        external_controller = "192.168.5.1:9090";
        external_ui = pkgs.fetchzip {
          url = "https://github.com/haishanh/yacd/archive/refs/heads/gh-pages.zip";
          hash = "sha256-SaVsY2kGd+v6mmjwXAHSgRBDBYCxpWDYFysCUPDZjlE=";
        };
      };
    };
  };
in {
  services.sing-box = {
    enable = true;
    settings = settings // extraSettings;
  };
  # 在运行一段时间后，inbounds 会堆积，导致内存占用过高，因此需要定时重启
  services.cron.systemCronJobs = [
    "*/30 * * * * root ${pkgs.systemd}/bin/systemctl restart sing-box"
  ];
  systemd.services.sing-box = {
    postStart = ''
      sed -i 's/server=127.0.0.1#5353/server=127.0.0.1#5355/g' /etc/special.conf
      # sed -i 's/^conf-dir=\/etc\/dnsmasq.d/#conf-dir=\/etc\/dnsmasq.d/g' /etc/special.conf
      systemctl restart dnsmasq
    '';
    postStop = ''
      sed -i 's/server=127.0.0.1#5355/server=127.0.0.1#5353/g' /etc/special.conf
      # sed -i 's/^#conf-dir=\/etc\/dnsmasq.d/conf-dir=\/etc\/dnsmasq.d/g' /etc/special.conf
      systemctl restart dnsmasq
    '';
  };
}
