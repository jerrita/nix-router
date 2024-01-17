{ config, pkgs, ... }:
{
    services.ddns = {
        enable = false;
        interval = "5min";
        apiToken = "***";
        domain = "";
        zone = "";
        nicName = "ppp0";
        ipv4UpdateMethod = "nic";  # nic/none/internet
    };
}