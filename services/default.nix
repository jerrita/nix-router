{ config, pkgs, ... }:
{
    imports = [
        ./offload.nix
        ./cron.nix
        # ./clash.nix
        # ./sing.nix  # has issues on router
        ./clash-tun.nix
        ./zerotier.nix
        ./ddns.nix
        ./upnp.nix
    ];
}