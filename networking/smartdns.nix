{
  config,
  pkgs,
  ...
}: {
  services.smartdns = {
    enable = true;
    settings = {
      bind = "[::]:5353";
      log-level = "info";
      log-size = "512K";
      mdns-lookup = "yes";

      conf-file = "/etc/smartdns/server.conf";

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
