{ config, pkgs, ... }:
{
    services.fail2ban = {
        enable = true;
        bantime-increment.enable = true;
        ignoreIP = [
            "192.168.5.0/24"
        ];
    };
}