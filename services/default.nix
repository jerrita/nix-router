{ config, pkgs, ... }:
{
    imports = [
        ./offload.nix
        ./cron.nix
        ./clash.nix           # user tun
        # ./sing.nix          # has issues on router
        # ./clash-legacy.nix  # use redir and tproxy
        ./zerotier.nix
        ./ddns.nix
        ./upnp.nix
    ];
}