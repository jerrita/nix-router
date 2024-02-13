{ config, pkgs, ... }:
{
    services.smartdns = {
        enable = true;
        settings = {
            bind = "[::]:5353";
            log-level = "info";
            log-size = "512K";

            server = [
                "61.132.163.68"
                "202.102.213.68"
                "223.5.5.5 -bootstrap-dns"
            ];
            dualstack-ip-selection = "yes";

            cache-size = 32768;
            cache-persist = "yes";
            serve-expired = "yes";
            prefetch-domain = "yes";
            serve-expired-ttl = 259200;
            serve-expired-reply-ttl = 3;
            serve-expired-prefetch-time = 21600;
            cache-checkpoint-time = 86400;
        };
    };
}