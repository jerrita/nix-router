{ config, pkgs, ... }:
{
    imports = [
        ./offload.nix
        ./cron.nix
        ./clash.nix
        ./zerotier.nix
        ./ddns.nix
        ./upnp.nix
    ];
}