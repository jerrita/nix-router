{ config, pkgs, ... }:
let
    settings = builtins.fromJSON (builtins.readFile ../static/sing.json);
    extraSettings = {
        log.level = "debug";
        dns = {
            servers = [
                { tag = "local"; address = "223.5.5.5"; detour = "direct"; }
                { tag = "remote"; address = "fakeip"; }
                { tag = "nxdomain"; address = "rcode://name_error"; }
            ];
            rules = [
                { geosite = "category-ads-all"; server = "nxdomain"; disable_cache = true; }
                { geosite = "geolocation-!cn"; query_type = ["A" "AAAA"]; server = "remote"; }
                { out_bound = "any"; server = "local"; }
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
                store_fakeip = true;
            };
            clash_api = {
                external_controller = "127.0.0.1:9090";
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
            systemctl restart dnsmasq

            PATH=/run/current-system/sw/bin:$PATH
        '';
        postStop = ''
            sed -i 's/server=127.0.0.1#5355/server=127.0.0.1#5353/g' /etc/special.conf
            systemctl restart dnsmasq

            PATH=/run/current-system/sw/bin:$PATH
        '';
    };
}