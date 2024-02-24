{ config, pkgs, ... }:
let
    settings = builtins.fromJSON (builtins.readFile ../static/sing.json);
    extraSettings = {
        log.level = "warn";
        dns = {
            servers = [
                { tag = "local"; address = "127.0.0.1:5353"; detour = "direct"; address_resolver = "bootstrap"; }
                { tag = "bootstrap"; address = "223.5.5.5"; detour = "direct"; }
                { tag = "remote"; address = "fakeip"; }
                { tag = "nxdomain"; address = "rcode://name_error"; }
            ];
            rules = [
                { geosite = "category-ads-all"; server = "nxdomain"; disable_cache = true; }
                { geosite = "geolocation-!cn"; query_type = ["A" "AAAA"]; server = "remote"; }
                { outbound = "any"; server = "local"; }
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
                # auto_route = true;
                # inet4_route_exclude_address = [
                #     "192.168.5.0/24"
                # ];
            }
        ];
        route = {
            rules = [
                { protocol = "dns"; outbound = "dns-out"; }
                { inbound = "dns-in"; outbound = "dns-out"; }
                { geosite = "category-ads-all"; outbound = "block"; }
                { geosite = "cn"; geoip = ["private" "cn"]; outbound = "direct"; }
            ];
            auto_detect_interface = true;
        };
        experimental = {
            cache_file = {
                enabled = true;
                store_fakeip = false;
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
    systemd.services.sing-box = {
        postStart = ''
            sed -i 's/server=127.0.0.1#5353/server=127.0.0.1#5355/g' /etc/special.conf
            # sed -i 's/^conf-dir=\/etc\/dnsmasq.d/#conf-dir=\/etc\/dnsmasq.d/g' /etc/special.conf
            systemctl restart dnsmasq
            declare -a ncn_list=(
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
            )
            for cidr in "''${ncn_list[@]}"; do
                ip route add $cidr via 172.19.0.2
            done
        '';
        postStop = ''
            sed -i 's/server=127.0.0.1#5355/server=127.0.0.1#5353/g' /etc/special.conf
            # sed -i 's/^#conf-dir=\/etc\/dnsmasq.d/conf-dir=\/etc\/dnsmasq.d/g' /etc/special.conf
            systemctl restart dnsmasq
            declare -a ncn_list=(
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
            )
            for cidr in "''${ncn_list[@]}"; do
                ip route delete $cidr via 172.19.0.2
            done
        '';
    };
}